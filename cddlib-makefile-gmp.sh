#!/bin/sh

# to be kept in sync with SED_GMP from cddlib/lib-src/Makefile.gmp.am

MakeGmp () {
	cat $1 | \
	sed -e 's/dd_/ddf_/g' \
		-e 's/cddf_/cdd_/g' \
		-e 's/mytype/myfloat/g' \
		-e 's/#include "cdd.h"/#include "cdd_f.h"/' \
		-e 's/#include "cddtypes.h"/#include "cddtypes_f.h"/' \
		-e 's/#include "cddmp.h"/#include "cddmp_f.h"/' \
		-e 's/__CDD_H/__CDD_HF/' \
		-e 's/__CDD_HFF/__CDD_HF/' \
		-e 's/__CDDMP_H/_CDDMP_HF/' \
		-e 's/__CDDTYPES_H/_CDDTYPES_HF/' \
		-e 's/GMPRATIONAL/ddf_GMPRATIONAL/g' \
		-e 's/ARITHMETIC/ddf_ARITHMETIC/g' \
		-e 's/CDOUBLE/ddf_CDOUBLE/g' \
		| awk "BEGIN{print \"/* generated automatically from $1 */\"}1" \
		> $2
}

pushd cddlib/lib-src
MakeGmp cdd.h      cdd_f.h
MakeGmp cddmp.h    cddmp_f.h
MakeGmp cddtypes.h cddtypes_f.h
MakeGmp cddcore.c  cddcore_f.c
MakeGmp cddlp.c    cddlp_f.c
MakeGmp cddmp.c    cddmp_f.c
MakeGmp cddio.c    cddio_f.c
MakeGmp cddlib.c   cddlib_f.c
MakeGmp cddproj.c  cddproj_f.c
popd
