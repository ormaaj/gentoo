# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop

DESCRIPTION="Open source chat client for Threema-style end-to-end encrypted chat networks"
HOMEPAGE="https://www.openmittsu.de/"
# snapshot of https://github.com/blizzard4591/openMittsu.git
# git-archive-all.sh --prefix ${P}/ -- - | xz > ${P}.tar.xz
SRC_URI="https://dev.gentoo.org/~ulm/distfiles/${P}.tar.xz"

LICENSE="GPL-2+ BitstreamVera OFL-1.1 Apache-2.0 CC0-1.0 MIT BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="dev-db/qt5-sqlcipher
	>=dev-libs/libsodium-1.0.18:=
	>=dev-qt/qtcore-5.7.1:5=
	>=dev-qt/qtgui-5.7.1:5=
	>=dev-qt/qtmultimedia-5.7.1:5=[widgets]
	>=dev-qt/qtnetwork-5.7.1:5=[ssl]
	>=dev-qt/qtsql-5.7.1:5=[sqlite]
	>=dev-qt/qtwidgets-5.7.1:5=
	>=media-gfx/qrencode-3.4.4-r1:="
DEPEND="${RDEPEND}
	test? ( >=dev-cpp/gtest-1.8.0 )"

DOCS=(
	README.md
	Example-client-configuration-file.ini
	Example-contacts-file.txt
)

CMAKE_BUILD_TYPE="Gentoo"

src_configure() {
	local mycmakeargs=(
		# set version manually, since autodetection works only with git
		"-DOPENMITTSU_CUSTOM_VERSION_STRING=${PV%.*}-${PV##*.}-00000000"
		"-DOPENMITTSU_DISABLE_VERSION_UPDATE_CHECK=ON"
		"-DOPENMITTSU_ENABLE_TESTS=$(usex test)"
	)
	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}" || die
	./openMittsuTests || die
}

src_install() {
	local my_pn="openMittsu"
	cmake_src_install
	newicon resources/icon.png ${my_pn}.png
	make_desktop_entry ${my_pn} ${my_pn} ${my_pn}
	rm "${ED}"/usr/bin/${my_pn}VersionInfo || die
	rm -f "${ED}"/usr/bin/${my_pn}Tests || die
}
