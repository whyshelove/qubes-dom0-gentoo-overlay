
EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit eutils multilib distutils-r1 flag-o-matic

Q=qubes-gui
if [[ ${PV} == *9999 ]]; then
	inherit qubes
	Q_PN=${Q}-${PN}
	EGIT_REPO_URI="https://github.com/QubesOS/${Q_PN}.git"
	S=$WORKDIR/${Q_PN}
else
	inherit rpm
	MY_PR=1
	MY_P=${Q}-${P}
	SRC_URI="https://mirrors.tuna.tsinghua.edu.cn/qubesos/repo/yum/r4.1/current-testing/dom0/fc32/rpm/${MY_P}-${MY_PR}.fc32.src.rpm"
	S=$WORKDIR/${MY_P}
fi

KEYWORDS="amd64"
HOMEPAGE="http://www.qubes-os.org"
LICENSE="GPLv2"

SLOT="0"
IUSE=""

DEPEND="qubes-core/libvchan
	qubes-gui/common
        qubes-core/qubesdb
	app-emulation/xen-tools
        x11-base/xorg-x11
	x11-libs/libXt
	x11-libs/libXext
	x11-libs/libXrandr
	dev-libs/libconfig
	media-libs/libpng
	x11-libs/libnotify
	sys-apps/help2man
	x11-base/xorg-server
	sys-libs/pam
        dev-python/pygobject[${PYTHON_USEDEP}]
        dev-python/pyxdg[${PYTHON_USEDEP}]
        media-libs/alsa-lib
        media-sound/alsa-utils
        media-sound/pulseaudio
        ${PYTHON_DEPS}
        "
RDEPEND="${DEPEND}
	qubes-misc/utils
	qubes-core/qrexec
	qubes-app/img-converter
	net-misc/socat
	dev-python/xcffib[${PYTHON_USEDEP}]"
PDEPEND=""


src_prepare() {
	default
}

src_configure() {
	py_opts="${py_opts} /usr/bin/python setup.py"
	export PYTHONDONTWRITEBYTECODE=
}

src_compile() {
	export BACKEND_VMM=xen
#	use socket && export BACKEND_VMM=socket
	emake all BACKEND_VMM=${BACKEND_VMM}

	${py_opts} build --executable="/usr/bin/python -s"
	sleep 1
}

src_install() {
	emake install DESTDIR=${D} INSTALL="/usr/bin/install -p"

	${py_opts} install -O1 --skip-build --root ${D}
	fowners root:qubes /usr/bin/qubes-guid
	chmod 4750 ${D}/usr/bin/qubes-guid
}

pkg_postinst() {
	# triggerin xorg-x11-server-Xorg
	ln -sf /usr/bin/X-wrapper-qubes /usr/bin/X
}

pkg_postrm() {
	# no more packages left
	ln -sf /usr/bin/Xorg /usr/bin/X
}
