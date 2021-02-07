# star-toolchain

This repo conatins a script to build the star-toolchain OCI container image which contains an embedded arm cross-toolchain, the mbed and zypher libraries and gdb/cgdb.

## Building a new Container Image

To build the container image from scratch install podman and buildah on a Fedora machine, update the arm toolchain download link at the top of the script to the latest one from [here](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) (Note: Theres one level of redirects here, you want an armkiel.blob.windows.net link), and then bump the releasever in the dnf line to the latest (Note: at time of writing mbed is broken with python3.9 so I have it on Fedora 32).

## Downloading a Prebuilt Image

Replace docker/podman with your OCI runtime of choice and run

```
docker/podman pull quay.io/ld_cd/star-toolchain
docker/podman volume create star-workspace # create a persistent directory to share with the container
docker/podman volume inspect star-workspace # See the mountpoint to access your workspace from the host.
```

## Building a Project
Once you have the container installed you can run it and build an mbed project like below:

```
podman run -it -w=/root/star-workspace -v star-workspace:/root/star-workspace star-toolchain bash --rcfile /etc/skel/.bashrc

mbed import https://github.com/ARMmbed/mbed-os-example-blinky
cd mbed-os-example-blinky
mbed compile --target NUCLEO_F401RE -t GCC_ARM
```
