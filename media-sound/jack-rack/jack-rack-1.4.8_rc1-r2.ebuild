# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic toolchain-funcs

MY_P=${PN}_${PV/_/\~}
DEB_URI="mirror://debian/pool/main/j/${PN}"

DESCRIPTION="JACK Rack is an effects rack for the JACK low latency audio API"
HOMEPAGE="https://jack-rack.sourceforge.net/"
SRC_URI="${DEB_URI}/${MY_P}.orig.tar.gz ${DEB_URI}/${MY_P}-1.debian.tar.gz"
S="${WORKDIR}/${PN}-f9fb65d"

# GPL-2+ for function in jack-rack-1.4.8_rc1-C23.patch
LICENSE="GPL-2 GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="alsa lash +xml"

RDEPEND="
	media-libs/ladspa-sdk
	virtual/jack
	virtual/libintl
	x11-libs/gtk+:2
	alsa? ( media-libs/alsa-lib:= )
	lash? ( media-sound/lash:= )
	xml? (
		dev-libs/libxml2:=
		media-libs/liblrdf:=
	)"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig"

PATCHES=(
	"${WORKDIR}"/debian/patches/01-desktop_file.patch
	"${WORKDIR}"/debian/patches/02-gcc45_binutils_gold.patch
	"${WORKDIR}"/debian/patches/03-remove_midi_when_replacing_plugin.patch
	"${FILESDIR}"/${PN}-1.4.6-noalsa.patch
	"${FILESDIR}"/${PN}-1.4.7-disable_deprecated.patch
	"${FILESDIR}"/${P}-noxml.patch
	"${FILESDIR}"/${P}-underlinking.patch
	"${FILESDIR}"/${P}-QA-fix-desktop-file.patch
	"${FILESDIR}"/${P}-C23.patch
)

src_prepare() {
	default
	eautopoint
	eautoreconf
}

src_configure() {
	# Use lrdf.pc to get -I/usr/include/raptor2 (lrdf.h -> raptor.h)
	use xml && append-cppflags $($(tc-getPKG_CONFIG) --cflags lrdf)

	econf \
		$(use_enable alsa aseq) \
		--disable-gnome \
		$(use_enable lash) \
		$(use_enable xml) \
		$(use_enable xml lrdf)
}
