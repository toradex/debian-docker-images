# Weston Touch Calibrator

Weston touch calibrator build pipeline for debian buster. weston-touch-calibrator is not included in the original debian buster packages. This adds an additional package which provides this binary. It can be used to calibrate resistive touch screens.

## Documentation
To calibrate a restive touch screen weston needs to be started in a way that it provides a calibration API. This should only be enabled during calibration as documented here:
https://www.mankier.com/5/weston.ini

Therefore, a special weston container can be used to do the initial touchscreen calibration. For that all running containers first need to be stopped:
```bash
docker stop $(docker ps -q)
```
Then the calibration container should be started:

```bash
docker run -ti --rm --privileged -v /dev:/dev -v /run/udev/:/run/udev/ -v /etc/udev/rules.d:/etc/udev/rules.d arm32v7-debian-weston-touch-calibrator
docker run -ti --rm --privileged -v /dev:/dev -v /run/udev/:/run/udev/ -v /etc/udev/rules.d:/etc/udev/rules.d -e ACCEPT_FSL_EULA=1 arm64v8-debian-weston-touch-calibrator
```
The container will automatically create a udev rule on the host system containing the calibration data.  After a reboot weston should be able to read the calibration values from the udev envrionment variable.
