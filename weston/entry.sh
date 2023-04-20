#!/usr/bin/env bash

# exits immediately if any error has non-zero exit
set -e
# don't allow forward referencing variables
set -u
# error the whole pipeline if a subcommand fails
set -o pipefail

declare -a WESTON_EXTRA_ARGS

# Only use long options to keep consistency.
# `option:` means the option has a non-optional arguments
# `option::` means the option has optional arguments
# `option` means the option has no arguments.
OPTIONS=developer,touch2pointer,tty:

WAYLAND_USER=${WAYLAND_USER:-torizon}
WESTON_ARGS=${WESTON_ARGS:--Bdrm-backend.so --current-mode -S${WAYLAND_DISPLAY}}
ENABLE_VNC=${ENABLE_VNC:-0}
ENABLE_RDP=${ENABLE_RDP:-0}
IGNORE_X_LOCKS=${IGNORE_X_LOCKS:-0}
IGNORE_VT_SWITCH_BACK=${IGNORE_VT_SWITCH_BACK:-0}

#
# Parse options.
#

# Pass `--options ''` to tell getopt we're not defining any short options
PARSED=$(getopt --options '' \
	--longoptions ${OPTIONS} \
	--name "$0" \
	-- "$@")
if [ $? -ne 0 ]; then
	echo "ERROR: getopt failed when setting up the options"
	exit 1
fi

eval set -- "${PARSED}"

COMMAND_HAS_DOUBLE_DASH=false
while [[ $# -ne 0 ]]; do
	case "$1" in
	--developer)
		export XDG_CONFIG_HOME=/etc/xdg/weston-dev
		echo "XDG_CONFIG_HOME=/etc/xdg/weston-dev" >>/etc/environment
		;;
	--touch2pointer)
		/usr/bin/touch2pointer "$1" &
		;;
	--tty)
		VT=${2:8}
		chvt "${VT}"
		;;
	--)
		COMMAND_HAS_DOUBLE_DASH=true
		;;
	*)
		if [ "$COMMAND_HAS_DOUBLE_DASH" = true ]; then
			WESTON_EXTRA_ARGS=("${WESTON_EXTRA_ARGS[@]}" "$1")
		fi
		;;
	esac
	shift
done
set -- "${WESTON_EXTRA_ARGS[@]}"

#
# Detect the SoC and supported features.
#

SOC_ID=''
SOC_ID_FILE='/sys/devices/soc0/soc_id'
test -e $SOC_ID_FILE && SOC_ID=$(<$SOC_ID_FILE)
if test -n "$SOC_ID"; then
	echo "SoC is: '$SOC_ID'"
else
	echo "Cannot detect SoC! Assuming it's GPU-capable."
fi
HAS_GPU=true
HAS_DPU=false

function has_feature() {
	FEATURE=$1
	PATTERNS_FILE=/etc/imx_features/${FEATURE}.socs
	ANSWER=false
	test -r "$PATTERNS_FILE" && grep -qf "$PATTERNS_FILE" <<<"$SOC_ID" && ANSWER=true
	echo $ANSWER
}

test -n "$SOC_ID" && {
	HAS_GPU=$(has_feature 'imxgpu')
	HAS_DPU=$(has_feature 'imxdpu')
}
echo "SoC has GPU: $HAS_GPU"
echo "SoC has DPU: $HAS_DPU"

#
# Decide on what g2d implementation must be enabled for weston.
#

G2D_IMPLEMENTATION='viv'
$HAS_DPU && G2D_IMPLEMENTATION='dpu'
echo "g2d implementation: $G2D_IMPLEMENTATION"
test -e /etc/alternatives/libg2d.so.1.5 && update-alternatives --set libg2d.so.1.5 /usr/lib/aarch64-linux-gnu/libg2d-${G2D_IMPLEMENTATION}.so

#
# Set desktop defaults.
#

function init_xdg() {
	if test -z "${XDG_RUNTIME_DIR}"; then
		XDG_RUNTIME_DIR=/tmp/$(id -u "${WAYLAND_USER}")-runtime-dir
		export XDG_RUNTIME_DIR
	fi

	echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}" >>/etc/environment

	if ! test -d "${XDG_RUNTIME_DIR}"; then
		mkdir -p "${XDG_RUNTIME_DIR}"
	fi

	chown "${WAYLAND_USER}" "${XDG_RUNTIME_DIR}"
	chmod 0700 "${XDG_RUNTIME_DIR}"

	# Create folder for XWayland Unix socket
	export X11_UNIX_SOCKET="/tmp/.X11-unix"
	if ! test -d "${X11_UNIX_SOCKET}"; then
		mkdir -p ${X11_UNIX_SOCKET}
	fi

	chown "${WAYLAND_USER}":video ${X11_UNIX_SOCKET}
}

init_xdg

#
# Make sure old VT is in text mode
#

function vt_setup() {
	# Some applications may leave old VT in graphics mode which causes
	# applications like openvt and chvt to hang at VT_WAITACTIVE ioctl when they
	# try to switch to a new VT
	OLD_VT=$(cat /sys/class/tty/tty0/active)
	OLD_VT_MODE=$(kbdinfo -C /dev/"${OLD_VT}" getmode)
	if [ "$OLD_VT_MODE" = "graphics" ]; then
		/usr/bin/switchvtmode.pl "${OLD_VT:3}" text
	fi
}

vt_setup

#
# Execute the weston compositor.
#

function init() {
	if CMD=$(command -v "$1" 2>/dev/null); then
		shift
		CMD="${CMD} $*"
		runuser -u "${WAYLAND_USER}" -- sh -c "${CMD}"
	else
		echo "Command not found: $1"
		exit 1
	fi
}

$HAS_GPU || $HAS_DPU || {
	echo "Fallbacking to software renderer."
	WESTON_ARGS="${WESTON_ARGS} --use-pixman"
}

REMOTE_UI="[screen-share]"
VNC_BACKEND="command=/usr/bin/weston --backend=vnc-backend.so --shell=fullscreen-shell.so"
RDP_BACKEND="command=/usr/bin/weston --backend=rdp-backend.so --shell=fullscreen-shell.so --no-clients-resize  --rdp-tls-key=/var/volatile/tls.key --rdp-tls-cert=/var/volatile/tls.crt --force-no-compression"
START_ON_STARTUP_CONFIG="start-on-startup=true"
CONFIGURATION_FILE=/etc/xdg/weston/weston.ini
CONFIGURATION_FILE_DEV=/etc/xdg/weston-dev/weston.ini

if [ "$ENABLE_VNC" = "1" ]; then
	MSG=$REMOTE_UI"\n$VNC_BACKEND\n"$START_ON_STARTUP_CONFIG
	echo -e "$MSG" | tee -a $CONFIGURATION_FILE $CONFIGURATION_FILE_DEV 1>/dev/null
fi

if [ "$ENABLE_RDP" = "1" ]; then
	mkdir -p /var/volatile
	{
		MSG=$REMOTE_UI"\n$RDP_BACKEND\n"$START_ON_STARTUP_CONFIG
		echo -e "$MSG" | tee -a $CONFIGURATION_FILE $CONFIGURATION_FILE_DEV 1>/dev/null

		if [ ! -f /var/volatile/tls.crt ] || [ ! -f /var/volatile/tls.key ]; then
			echo "Certificates for RDP not found in /var/volatile"
			cd /var/volatile || exit
			openssl genrsa -out tls.key 2048 &&
				openssl req -new -key tls.key -out tls.csr \
					-subj "/C=CH/ST=Luzern/L=Luzern/O=Toradex/CN=www.toradex.com" &&
				openssl x509 -req -days 365 -signkey tls.key \
					-in tls.csr -out tls.crt
			chmod 0644 tls.key tls.crt
			if [ -f "tls.crt" ]; then
				echo "Certificate for RDP successfully generated"
			else
				echo "Error generating certificate for RDP"
			fi
			cd || exit
		else
			echo "Certificates for RDP found in /var/volatile. Skipping generation."
		fi
	} 2>&1 | tee -a /var/volatile/weston.log
fi

if [ "$IGNORE_X_LOCKS" != "1" ]; then
	echo "Removing previously created '.X*-lock' entries under /tmp before starting Weston. Pass 'IGNORE_X_LOCKS=1' environment variable to Weston container to disable this behavior."
	rm -rf /tmp/.X*-lock
fi

function cleanup() {
	if [ "$IGNORE_VT_SWITCH_BACK" != "1" ]; then
		# switch back to tty1, otherwise the console screen is not displayed.
		echo "Switching back to vt ${OLD_VT:3}"
		chvt "${OLD_VT:3}"
	fi
}

trap cleanup EXIT

dos2unix $CONFIGURATION_FILE
dos2unix $CONFIGURATION_FILE_DEV

# for every argument after "--", append that argument to WESTON_ARGS
for i in "${!WESTON_EXTRA_ARGS[@]}"; do
	WESTON_ARGS+=" "${WESTON_EXTRA_ARGS[$i]}
done

init seatd-launch -- weston "${WESTON_ARGS}"
