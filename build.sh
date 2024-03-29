ARM_TOOLCHAIN="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-x86_64-linux.tar.bz2"

container=$(buildah from fedora)

echo "LOGGING into quay.io as $QUAY_USERNAME"
podman login -u $QUAY_USERNAME -p $QUAY_PASSWORD quay.io

echo
echo "INSTALLING base packages:"
buildah run $container -- dnf install \
	bash coreutils python3 python3-pip git mercurial rust \
	bash-completion cmake gperf dfu-util dtc tar wget curl \
	python3-devel python3-setuptools python3-wheel \
	xz bzip2 file make automake gcc gcc-c++ \
	python3-intelhex cgdb ncurses ncurses-compat-libs \
	--setopt install_weak_deps=false -y

echo
echo "DOWNLOADING ARM toolchain from $ARM_TOOLCHAIN:"
buildah run $container -- curl $ARM_TOOLCHAIN -o /opt/toolchain.tar.bz2
buildah run $container -- bash -c "cd /opt && tar jxf toolchain.tar.bz2 && rm toolchain.tar.bz2 && mv * arm-toolchain"

echo
echo "CONFIGURING environment:"
buildah run $container -- bash -c "echo 'PATH=$PATH:/opt/arm-toolchain/bin/;export PATH' >> /etc/profile"
buildah run $container -- bash -c "cp /etc/skel/.bashrc /root/ && chmod 755 /root/.bashrc"
buildah run $container -- bash -c "echo 'source /etc/profile' >> /root/.bashrc"

echo
echo "INSTALLING MBED:"
buildah run $container -- python3 -m pip --no-input install mbed-cli
buildah run $container -- mbed config -G GCC_ARM_PATH "/opt/arm-toolchain/bin"
buildah run $container -- python3 -m pip --no-input install -r \
	"https://raw.githubusercontent.com/ARMmbed/mbed-os/master/requirements.txt"
buildah run $container -- python3 -m pip --no-input install jsonschema mbed_cloud_sdk \
	mbed_ls mbed_host_tests mbed_greentea manifest_tool icetea pycryptodome


echo
echo "BUILT star-toolchain-nozephyr"
echo "COMMITING to star-toolchain-nozephyr:"
buildah commit $container star-toolchain-nozephyr
df -h
podman push localhost/star-toolchain-nozephyr quay.io/$QUAY_USERNAME/star-toolchain-nozephyr
podman rmi localhost/star-toolchain-nozephyr

buildah run $container -- dnf install \
	ccache dtc SDL2-devel python3-tkinter ninja-build \
	--setopt install_weak_deps=false -y

buildah run $container -- python3 -m pip --no-input install west
buildah run $container -- west init /opt/zephyrproject
buildah run $container -- bash -c "cd /opt/zephyrproject && west update && west zephyr-export"
buildah run $container -- pip3 install -r /opt/zephyrproject/zephyr/scripts/requirements.txt

buildah run $container -- bash -c "curl 'https://gist.githubusercontent.com/ld-cd/16e2a0669d5c20b430753cfca5432a6a/raw/1fc6296f5d2816d994446a536ff64edfbf4bd656/.zypherrc' >> /etc/profile"

echo
echo "COMMITING to star-toolchain:"
buildah commit $container star-toolchain
df -h
podman push localhost/star-toolchain quay.io/$QUAY_USERNAME/star-toolchain
