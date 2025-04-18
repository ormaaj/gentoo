# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_EXAMPLES="false"
ECM_QTHELP="false"
ECM_TEST="true"
KDE_ORG_TAR_PN="${PN}2"
QTMIN=5.15.9
inherit ecm frameworks.kde.org toolchain-funcs

DESCRIPTION="Lightweight user interface framework for mobile and convergent applications"
HOMEPAGE="https://community.kde.org/Kirigami"

LICENSE="LGPL-2+"
KEYWORDS="amd64 ~arm arm64 ~loong ppc64 ~riscv ~x86"
IUSE="openmp"

# requires package to already be installed
RESTRICT="test"

DEPEND="
	>=dev-qt/qtconcurrent-${QTMIN}:5
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtdeclarative-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtnetwork-${QTMIN}:5
	>=dev-qt/qtquickcontrols2-${QTMIN}:5
	>=dev-qt/qtsvg-${QTMIN}:5
"
RDEPEND="${DEPEND}
	>=dev-qt/qtgraphicaleffects-${QTMIN}:5
"
BDEPEND=">=dev-qt/linguist-tools-${QTMIN}:5"

PATCHES=( "${FILESDIR}/${P}-fix-loading-desktop-theme.patch" )

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_EXAMPLES=OFF
		$(cmake_use_find_package openmp OpenMP)
	)

	ecm_src_configure
}
