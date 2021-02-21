# star-toolchain

This repo conatins a script to build the star-toolchain OCI container image which contains an embedded arm cross-toolchain, the mbed and zypher libraries and gdb/cgdb.

## Building a new Container Image

To update the image on quay simply commit your changes to this repo and a build will automatically be triggered which you can view on the github actions page. You will likely want to update the arm toolchain download link at the top of the script to the latest one from [here](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) (Note: Theres one level of redirects here, you want an armkiel.blob.windows.net link).

## Downloading a Prebuilt Image

We distribute two different container images, the `star-toolchain` image which is the whole shebang and is quite big (6 gigabytes uncompressed), and the `star-toolchain-nozephyr` image which is only about a gigabyte, and is recommended if you are only working with ARM platforms.

To download an image from quay, decide what image you want (`star-toolchain` or `star-toolchain-nozephyr`), replace docker/podman with your OCI runtime of choice and run:

```bash
docker/podman pull quay.io/star_admin/star-toolchain[-nozephyr]
docker/podman volume create star-workspace # create a persistent directory to share with the container
docker/podman volume inspect star-workspace # See the mountpoint to access your workspace from the host.
docker/podman container create -d -it -w=/root/star-workspace --name star-toolbox -v star-workspace:/root/star-workspace star-toolchain[-nozephyr] bash
```

## Opening With VS Code

If you are on Windows/Mac transfering files in and out of the container can be quite a pain, because windows sucks. To solve this problem we recommend using VS Code to connect to your container, this lets you transfer files easily with drag and drop and makes starting and managing the container more seamless. In order to set this up you are going to want to install VS Code and the [remote containers](https://code.visualstudio.com/docs/remote/containers-tutorial) extension.

Once you've got all that setup you're going to want to go to the "Remote Explorer" tab on the left bar of VS Code, right click on the container you created in the previous step and click attach to start a VS Code instance in the container. From here you should be able to open a terminal inside the container by going to `Terminal->New Terminal` and interact with the filesystem through VS Code and clone stuff, open folders, etc

This step is not strictly required, you can in theory just install the container and enter and exit it through `docker/podman` commands.

## Building a Project

Open a terminal either through VS Code or with `podman start star-toolbox && podman exec -it star-toolbox bash` in your own terminal and build a test project with:

```bash
mbed import https://github.com/ARMmbed/mbed-os-example-blinky
cd mbed-os-example-blinky
mbed compile --target NUCLEO_F401RE -t GCC_ARM
```
