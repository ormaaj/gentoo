# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic

DESCRIPTION="NAST - Network Analyzer Sniffer Tool"
HOMEPAGE="https://sourceforge.net/projects/nast.berlios/"
SRC_URI="https://downloads.sourceforge.net/${PN}.berlios/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 x86"
IUSE="ncurses"

RDEPEND="
	>=net-libs/libnet-1.1.1
	net-libs/libpcap
	ncurses? ( >=sys-libs/ncurses-5.4:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-gentoo.patch
	"${FILESDIR}"/0001-Fix-signal-handler.patch
	"${FILESDIR}"/0002-Fix-Wformat-security.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	append-cflags -fcommon
	default
}

src_compile() {
	emake CFLAGS="${CFLAGS}"
}

src_install() {
	dosbin nast
	doman nast.8
	dodoc AUTHORS BUGS CREDITS ChangeLog NCURSES_README README TODO
}
