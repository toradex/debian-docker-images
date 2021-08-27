
# Torizon Docker Debian-based container images

Build customized Docker image by running:
```
docker build --pull -t <username>/<my-container-image> .
```
Make sure to select desired architecture by (un)commenting the arguments in Dockerfiles.

**Weston**

Run this script before building Weston Docker image:
```
weston/make_feature_map.sh
```

**Known issues**

To avoid ldconfig segmentation faults during build, use latest qemu-user-static by running:
```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```
