#!/bin/bash

set -x

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq update
DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	appstream \
	automake \
	autotools-dev \
	build-essential \
	checkinstall \
	cmake \
	curl \
	devscripts \
	equivs \
	extra-cmake-modules \
	gettext \
	git \
	gnupg2 \
	lintian \
	wget

### Add Neon Sources

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Package Build Dependencies #1

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	appstream \
	kirigami2-dev \
	libkf5activities-dev \
	libkf5activitiesstats-dev \
	libkf5archive-dev \
	libkf5crash-dev \
	libkf5declarative-dev \
	libkf5i18n-dev \
	libkf5kcmutils-dev \
	libkf5kio-dev \
	libkf5networkmanagerqt-dev \
	libkf5newstuff-dev \
	libkf5notifications-dev \
	libkf5plasma-dev \
	libkf5solid-dev \
	libkf5wayland-dev \
	libqt5svg5-dev \
	libqt5x11extras5-dev \
	libxcb-randr0-dev \
	libxcb-shape0-dev \
	libxcb-util-dev \
	plasma-workspace-dev \
	qml-module-qtgraphicaleffects \
	qml-module-qtquick-controls \
	qml-module-qtquick-shapes \
	qt5-qmake  \
	qtbase5-dev \
	qtbase5-dev-tools  \
	qtchooser  \
	qtdeclarative5-dev \
	qtmultimedia5-dev  \
	qtquickcontrols2-5-dev  \
	qttools5-dev

### Clone Repository

git clone --depth 1 --branch v0.10 https://github.com/KDE/latte-dock.git

rm -rf latte-dock/{CHANGELOG.md,LICENSES,README.md,INSTALLATION.md,NEWFEATURES.md,logo.png}

### Compile Source

mkdir -p latte-dock//build && cd latte-dock//build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DKDE_INSTALL_USE_QT_SYS_PATHS=true \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ..

make

### Run checkinstall and Build Debian Package
### DO NOT USE debuild, screw it

>> description-pak printf "%s\n" \
	'Dock based on plasma frameworks.' \
	'' \
	'Latte is a dock based on plasma frameworks that provides an elegant and' \
	'intuitive experience for your tasks and plasmoids.' \
	'' \
	'It animates its contents by using parabolic zoom effect and tries to be there only when' \
	'it is needed.' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=latte-dock \
	--pkgversion=0.10.801+nitrux+git \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=lib \
	--pkgsource=latte-dock \
	--pakdir=../.. \
	--maintainer=uri_herrera@nxos.org \
	--provides=latte-dock \
	--requires=libc6,libkf5configcore5,libkf5coreaddons5,libkf5i18n5,libkf5notifications5,libqt5core5a,libqt5gui5,libqt5qml5,libstdc++6,qml-module-org-kde-kirigami2,qml-module-qtquick-controls2,qml-module-qtquick-shapes \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
