# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="Padauk"
inherit font

DESCRIPTION="SIL fonts for Myanmar script"
HOMEPAGE="https://software.sil.org/padauk/"
SRC_URI="https://software.sil.org/downloads/r/padauk/${MY_PN}-${PV}.zip"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~hppa ~loong ppc ppc64 ~riscv ~s390 sparc x86"

BDEPEND="app-arch/unzip"

FONT_SUFFIX="ttf"
