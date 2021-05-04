if [ -f "/tmp/nxp-eula-accepted" ]; then
    echo "NXP EULA has already been accepted."
elif [ ! -n "$BASH" ]; then
    # Interactive shell detection is bashism. Do not bother if we cannot detect.
    echo "WARNING: NXP EULA has been auto-accepted; this imply you agree with it anyway."
elif [ "${ACCEPT_FSL_EULA}" != "1" ]; then
    cat <<EOMESSAGE
This container uses Vivante binary drivers provided by NXP. You need to read
and accept the NXP EULA before continuing..

EOMESSAGE

    # In case we run non-interactively, ask the user to accept through environment
    if [[ $- != *i* ]]; then
         cat <<EOMESSAGE
Start an interactive shell to read the NXP EULA. Alternatively set the
environment variable ACCEPT_FSL_EULA=1 to accept the EULA non-interacitvely.
EOMESSAGE
        exit 1
    fi

    sleep 2

    cat | more -d </etc/LA_OPT_NXP_SW.txt

    echo -n "Do you accept the Vivante EULA you just read? (y/N) "
    read REPLY
    if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
        echo "NXP EULA has not been accepted..."
        exit 1
    fi

    echo "NXP EULA has been accepted."
    echo
fi

# If we get here, EULA has been auto-accepted or interactively accepted.
# Further login shells should not need to accept EULA again
touch /tmp/nxp-eula-accepted
