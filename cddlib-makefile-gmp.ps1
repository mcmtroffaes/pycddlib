# to be kept in sync with SED_GMP from cddlib/lib-src/Makefile.gmp.am

function MakeGmp {
    param( [string]$InFile, [string]$OutFile )
    (Get-Content $InFile) | 
    Foreach-Object {
        $_ -creplace 'dd_','ddf_' `
           -creplace 'cddf_','cdd_' `
           -creplace 'mytype','myfloat' `
           -creplace '#include "cdd.h"','#include "cdd_f.h"' `
           -creplace '#include "cddtypes.h"','#include "cddtypes_f.h"' `
           -creplace '#include "cddmp.h"','#include "cddmp_f.h"' `
           -creplace '__CDD_H','__CDD_HF' `
           -creplace '__CDD_HFF','__CDD_HF' `
           -creplace '__CDDMP_H','_CDDMP_HF' `
           -creplace '__CDDTYPES_H','_CDDTYPES_HF' `
           -creplace 'GMPRATIONAL','ddf_GMPRATIONAL' `
           -creplace 'ARITHMETIC','ddf_ARITHMETIC' `
           -creplace 'CDOUBLE','ddf_CDOUBLE'
    }  | Set-Content $OutFile
}

pushd cddlib\lib-src
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
