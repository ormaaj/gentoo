# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=WADG
DIST_VERSION=0.63
inherit perl-module

DESCRIPTION="Create 3D Graphs with GD and GD::Graph"

SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"

RDEPEND="
	>=dev-perl/GD-1.180.0
	>=dev-perl/GDGraph-1.300.0
	dev-perl/GDTextUtil
"
BDEPEND="${RDEPEND}
"
