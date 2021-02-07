ARM_TOOLCHAIN="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2"

container=$(buildah from scratch)
mount=$(buildah mount $container)

dnf install --installroot $mount --releasever 32 \
	bash coreutils python3 python3-pip git mercurial rust \
	bash-completion cmake ninja-build gperf ccache dfu-util \
	dtc tar wget curl python3-devel python3-setuptools python3-wheel \
	xz bzip2 file python3-tkinter make automake gcc gcc-c++ SDL2-devel \
	python3-intelhex cgdb ncurses \
	--setopt install_weak_deps=false -y

echo "Downloading ARM toolchain from $ARM_TOOLCHAIN"
buildah run $container -- curl $ARM_TOOLCHAIN -o /opt/toolchain.tar.bz2
buildah run $container -- bash -c "cd /opt && tar jxf toolchain.tar.bz2 && rm toolchain.tar.bz2 && mv * arm-toolchain"

buildah run $container -- bash -c "echo 'PATH=$PATH:/opt/arm-toolchain/bin/;export PATH' >> /etc/profile"

buildah run $container -- python3 -m pip --no-input install mbed-cli
buildah run $container -- mbed config -G GCC_ARM_PATH "/opt/arm-toolchain/bin"
buildah run $container -- python3 -m pip --no-input install jsonschema mbed_cloud_sdk \
	mbed_ls mbed_host_tests mbed_greentea manifest_tool icetea pycryptodome

buildah run $container -- python3 -m pip --no-input install west
buildah run $container -- west init /opt/zephyrproject
buildah run $container -- bash -c "cd /opt/zephyrproject && west update && west zephyr-export"
buildah run $container -- pip3 install -r /opt/zephyrproject/zephyr/scripts/requirements.txt

buildah run $container -- bash -c "curl 'https://gist.githubusercontent.com/ld-cd/16e2a0669d5c20b430753cfca5432a6a/raw/1fc6296f5d2816d994446a536ff64edfbf4bd656/.zypherrc' >> /etc/profile'"

echo
echo "Commiting to star-toolchain:"
buildah commit $container star-toolchain
