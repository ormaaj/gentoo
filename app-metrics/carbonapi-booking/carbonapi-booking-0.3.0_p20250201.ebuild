# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

COMMIT=8881b346c8579862a34c4ab46314501117e339dc
MY_PN=${PN%-booking}
DESCRIPTION="High-performance Graphite front-end, Booking.com fork"
HOMEPAGE="https://github.com/bookingcom/carbonapi"
SRC_URI="https://github.com/bookingcom/carbonapi/archive/${COMMIT}.zip -> ${P}.zip"

S="${WORKDIR}/${MY_PN}-${COMMIT}"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	app-arch/bzip2
	dev-libs/expat
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libpng
	x11-libs/cairo[X]
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXrender
	x11-libs/pixman
"
RDEPEND="${DEPEND}
	acct-group/carbon
	acct-user/carbon"
BDEPEND=""

src_prepare() {
	export VERSION="gentoo-${PVR}"

	# bug 904051: disable data-race detection, conflicts with
	# go-module's -buildmode=pie
	sed -i -e 's/ -race / /' Makefile || die

	eapply "${FILESDIR}"/${P}-logfile.patch
	eapply "${FILESDIR}"/${P}-colours.patch

	eapply_user
}

src_install() {
	insinto /etc/carbonapi
	doins -r "${S}"/config/*
	dobin carbonapi

	newinitd "${FILESDIR}"/${PN}.initd carbonapi
	newconfd "${FILESDIR}"/${PN}.confd carbonapi
}
