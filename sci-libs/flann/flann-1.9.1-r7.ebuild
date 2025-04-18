# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake cuda flag-o-matic toolchain-funcs

DESCRIPTION="Fast approximate nearest neighbor searches in high dimensional spaces"
HOMEPAGE="https://github.com/mariusmuja/flann"
SRC_URI="https://github.com/mariusmuja/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc ~x86 ~amd64-linux ~x86-linux"
IUSE="cuda doc examples mpi octave openmp"

BDEPEND="
	app-arch/unzip
	doc? ( dev-tex/latex2html )
	mpi? ( app-admin/chrpath )
"
DEPEND="
	app-arch/lz4:=
	cuda? ( >=dev-util/nvidia-cuda-toolkit-5.5 )
	mpi? (
		dev-libs/boost:=[mpi]
		sci-libs/hdf5:=[mpi]
	)
	!mpi? ( !sci-libs/hdf5[mpi] )
	octave? ( >=sci-mathematics/octave-3.6.4-r1:= )
"
RDEPEND="${DEPEND}"
# TODO:
# readd dependencies for test suite,
# requires multiple ruby dependencies

PATCHES=(
	"${FILESDIR}"/${P}-cmake-3.11{,-1}.patch # bug 678030
	"${FILESDIR}"/${P}-cuda-9.patch
	"${FILESDIR}"/${P}-system-lz4.patch # bug 681898
	"${FILESDIR}"/${P}-system-lz4-pkgconfig.patch # bug 827263
	"${FILESDIR}"/${P}-build-oct-rather-than-mex-files-for-octave.patch # bug 830424
	"${FILESDIR}"/${P}-boost-1.87.patch # bug 946465
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	# bug #302621
	use mpi && export CXX=mpicxx

	use cuda && cuda_src_prepare

	cmake_src_prepare
}

src_configure() {
	append-cxxflags -std=c++11

	# python bindings are split off into dev-python/pyflann
	local mycmakeargs=(
		-DBUILD_C_BINDINGS=ON
		-DBUILD_PYTHON_BINDINGS=OFF
		-DPYTHON_EXECUTABLE=
		-DBUILD_CUDA_LIB=$(usex cuda)
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_DOC=$(usex doc)
		-DBUILD_TESTS=OFF
		-DBUILD_MATLAB_BINDINGS=$(usex octave)
		-DUSE_MPI=$(usex mpi)
		-DUSE_OPENMP=$(usex openmp)
	)
	use cuda && mycmakeargs+=(
		-DCUDA_NVCC_FLAGS="${NVCCFLAGS} --linker-options \"-arsch\""
	)
	use doc && mycmakeargs+=( -DDOCDIR=share/doc/${PF} )

	cmake_src_configure
}

src_install() {
	cmake_src_install
	find "${D}" -name 'lib*.a' -delete || die

	# bug 795828; mpicc volunterely adds some runpaths
	if use mpi; then
		chrpath -d "${ED}"/usr/bin/flann_mpi_{client,server} || die
	fi
}
