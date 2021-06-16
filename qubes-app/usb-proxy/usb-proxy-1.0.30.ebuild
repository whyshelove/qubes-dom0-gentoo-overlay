
EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit eutils multilib distutils-r1

iQ=qubes-app-linux
if [[ ${PV} == *9999 ]]; then
	inherit qubes
	Q_PN=${Q}-${PN}
	EGIT_REPO_URI="https://github.com/QubesOS/${Q_PN}.git"
	S=$WORKDIR/${Q_PN}
else
	inherit rpm
	MY_PR=1
	MY_PF=qubes-${PN}-dom0-${PV}-${MY_PR}
	SRC_URI="https://mirrors.tuna.tsinghua.edu.cn/qubesos/repo/yum/r4.1/current-testing/dom0/fc32/rpm/${MY_PF}.fc32.src.rpm"
	S=$WORKDIR/qubes-${P}
fi

KEYWORDS="amd64"
DESCRIPTION="USBIP wrapper to run it over Qubes RPC connection"
HOMEPAGE="http://www.qubes-os.org"
LICENSE="GPLv2"

SLOT="0"
IUSE=""

DEPEND="sys-apps/usbutils
        ${PYTHON_DEPS}
        "
RDEPEND="${DEPEND}"
PDEPEND=""

src_prepare() {
    default
}

src_install() {
	export PYTHONDONTWRITEBYTECODE=
	emake install-dom0 DESTDIR=${D}
}
