# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
inherit autotools python-single-r1 xdg-utils

DESCRIPTION="A library for manipulating block devices"
HOMEPAGE="https://github.com/storaged-project/libblockdev"
if [[ "${PV}" == *9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/storaged-project/libblockdev.git"
	BDEPEND="
		sys-devel/autoconf-archive
	"
else
	MY_PV="${PV}-1"
	#MY_P="${PN}-${MY_PV}"
	#SRC_URI="https://github.com/storaged-project/${PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	SRC_URI="https://github.com/storaged-project/${PN}/releases/download/${MY_PV}/${P}.tar.gz"
	KEYWORDS="~alpha amd64 arm arm64 ~ia64 ~mips ppc ppc64 sparc x86"
	#S="${WORKDIR}/${MY_P}"
fi
LICENSE="LGPL-2+"
SLOT="0"
IUSE="bcache +cryptsetup +device-mapper +dmraid +loop +swap mpath escrow gtk-doc introspection lvm kbd test +tools vdo"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.42.2
	dev-libs/libbytesize
	>=sys-apps/kmod-19
	>=sys-apps/util-linux-2.27
	>=sys-block/parted-3.1
	cryptsetup? (
		escrow? (
			>=dev-libs/nss-3.18.0
			dev-libs/volume_key
		)
		>=sys-fs/cryptsetup-1.6.7:=
	)
	device-mapper? ( sys-fs/lvm2 )
	dmraid? (
		sys-fs/dmraid
		sys-fs/lvm2
	)
	lvm? (
		sys-fs/lvm2
		virtual/udev
	)
	vdo? ( dev-libs/libyaml )
	${PYTHON_DEPS}
"

DEPEND="
	${RDEPEND}
"

BDEPEND+="
	dev-util/gtk-doc-am
	gtk-doc? ( dev-util/gtk-doc )
	introspection? ( >=dev-libs/gobject-introspection-1.3.0 )
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
		escrow? ( cryptsetup )"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	xdg_environment_reset #623992
	default

	# https://bugs.gentoo.org/744289
	find -type f \( -name "Makefile.am" -o -name "configure.ac" \) -print0 \
		| xargs --null sed "s@ -Werror@@" -i || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-btrfs
		--with-fs
		--with-part
		--without-nvdimm
		$(use_enable introspection)
		$(use_enable test tests)
		$(use_with bcache)
		$(use_with cryptsetup crypto)
		$(use_with device-mapper dm)
		$(use_with dmraid)
		$(use_with loop)
		$(use_with swap)
		$(use_with mpath) 
		$(use_with escrow)
		$(use_with gtk-doc)
		$(use_with kbd)
		$(use_with lvm lvm)
		$(use_with lvm lvm-dbus)
		$(use_with tools)
		$(use_with vdo)
		--without-python2
		--with-python3
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
	# This is installed even with USE=-lvm, but libbd_lvm are omitted so it
	# doesn't work at all.
	if ! use lvm; then
		rm -f "${ED}"/usr/bin/lvm-cache-stats || die
	fi
	python_optimize #718576
}
