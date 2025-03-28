# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Verification-aware programming language"
HOMEPAGE="https://dafny.org/
	https://github.com/dafny-lang/dafny/"
SRC_URI="https://github.com/dafny-lang/dafny/releases/download/v${PV}/dafny-${PV}-x64-ubuntu-20.04.zip"
S="${WORKDIR}/dafny"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="strip"

RDEPEND="
	!dev-lang/dafny
	dev-libs/userspace-rcu
	dev-util/lttng-ust:0/2.12
	sci-mathematics/z3
"
BDEPEND="
	app-arch/unzip
"

QA_PREBUILT="*"

src_prepare() {
	default

	# Remove bundled z3.
	# NOTICE: New versions do not need the bundled one but older versions
	# hardcoded the path relative to "dafny" binary.
	# While bumping make sure to verify that system's "z3" is used
	# by, for example, compiling/verifying a simple dafny program.
	rm -r z3 || die
}

src_install() {
	local dest="/opt/dafny"

	insinto "${dest}"
	# Maybe too general, but this installation mode matched how it arrives.
	insopts -m0755
	doins "${S}"/*

	local bin
	for bin in DafnyServer dafny ; do
		dosym "../../${dest}/${bin}" "/usr/bin/${bin}"
	done

	# Make "dafny-server" clients happy.
	dosym -r "/${dest}/DafnyServer" /usr/bin/dafny-server
}
