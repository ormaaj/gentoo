# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic plocale xdg

PLOCALES="ca_ES cs_CZ de_DE es_AR es_ES es_MX et_EE fi_FI fr_FR hu_HU id_ID it_IT ja_JP ko_KR nb_NO nl_NL pl_PL pt_BR ru_RU sv_SE tr_CY tr_TR uk_UA zh_CN zh_TW"

DESCRIPTION="Modern music player and library organizer based on Clementine and Qt"
HOMEPAGE="https://www.strawberrymusicplayer.org/"
if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/strawberrymusicplayer/strawberry"
	inherit git-r3
else
	SRC_URI="https://github.com/strawberrymusicplayer/strawberry/releases/download/${PV}/${P}.tar.xz"
	KEYWORDS="amd64 ~arm64 ~ppc64 x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="cdda debug +gstreamer ipod moodbar mtp pulseaudio qt6 soup +udisks vlc"

BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
	!qt6? ( dev-qt/linguist-tools:5 )
"
COMMON_DEPEND="
	dev-db/sqlite:=
	dev-libs/glib:2
	dev-libs/icu:=
	dev-libs/protobuf:=
	media-libs/alsa-lib
	media-libs/taglib
	!qt6? (
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtdbus:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5[ssl]
		dev-qt/qtsql:5[sqlite]
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
		x11-libs/libX11
	)
	qt6? (
		dev-libs/kdsingleapplication[qt6(+)]
		dev-qt/qtbase:6[concurrent,dbus,gui,network,ssl,sql,sqlite,widgets]
	)
	cdda? ( dev-libs/libcdio:= )
	gstreamer? (
		media-libs/chromaprint:=
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	ipod? ( media-libs/libgpod )
	moodbar? ( sci-libs/fftw:3.0 )
	mtp? ( media-libs/libmtp )
	pulseaudio? ( media-libs/libpulse )
	vlc? ( media-video/vlc )
"
# Note: sqlite driver of dev-qt/qtsql is bundled, so no sqlite use is required; check if this can be overcome someway;
RDEPEND="${COMMON_DEPEND}
	gstreamer? (
		media-plugins/gst-plugins-meta:1.0
		soup? ( media-plugins/gst-plugins-soup:1.0 )
		media-plugins/gst-plugins-taglib:1.0
	)
	mtp? ( gnome-base/gvfs[mtp] )
	udisks? ( sys-fs/udisks:2 )
"
DEPEND="${COMMON_DEPEND}
	dev-cpp/gtest
	dev-libs/boost
	!qt6? ( dev-qt/qttest:5 )
"

DOCS=( Changelog README.md )

REQUIRED_USE="
	cdda? ( gstreamer )
	|| ( gstreamer vlc )
"

src_prepare() {
	plocale_find_changes "src/translations" "" ".po"

	cmake_src_prepare
}

src_configure() {
	# spotify is not in portage
	local mycmakeargs=(
		-DBUILD_WERROR=OFF
		# avoid automagically enabling of ccache (bug #611010)
		-DCCACHE_EXECUTABLE=OFF
		-DENABLE_GIO=ON
		-DLINGUAS="$(plocale_get_locales)"
		-DENABLE_AUDIOCD="$(usex cdda)"
		-DENABLE_GSTREAMER="$(usex gstreamer)"
		-DENABLE_LIBGPOD="$(usex ipod)"
		-DENABLE_LIBMTP="$(usex mtp)"
		-DENABLE_LIBPULSE="$(usex pulseaudio)"
		-DENABLE_MOODBAR="$(usex moodbar)"
		-DENABLE_MUSICBRAINZ="$(usex gstreamer)"
		-DENABLE_SONGFINGERPRINTING="$(usex gstreamer)"
		-DENABLE_SPOTIFY="$(usex gstreamer)"
		-DENABLE_UDISKS2="$(usex udisks)"
		-DENABLE_VLC="$(usex vlc)"
		-DBUILD_WITH_QT6="$(usex qt6)"
		-DBUILD_WITH_QT5="$(usex !qt6)"
		-DQT_VERSION_MAJOR="$(usex qt6 6 5)"
	)

	use !debug && append-cppflags -DQT_NO_DEBUG_OUTPUT

	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst

	if use gstreamer ; then
		elog "Note that list of supported formats is controlled by media-plugins/gst-plugins-meta "
		elog "USE flags. You may be interested in setting aac, flac, mp3, ogg or wavpack USE flags "
		elog "depending on your preferences"
	fi
}
