# to be kept in sync with SED_GMP from cddlib/lib-src/Makefile.gmp.am

function MakeGmp {
    param( [string]$InFile, [string]$OutFile )
    (Get-Content $InFile) | 
    Foreach-Object {
        $_ -replace 'dd_','ddf_' `
           -replace 'cddf_','cdd_' `
           -replace 'mytype','myfloat' `
           -replace '#include "cdd.h"','#include "cdd_f.h"' `
           -replace '#include "cddtypes.h"','#include "cddtypes_f.h' `
           -replace '#include "cddmp.h"','#include "cddmp_f.h' `
           -replace '__CDD_H','__CDD_HF' `
           -replace '__CDD_HFF','__CDD_HF' `
           -replace '__CDDMP_H','_CDDMP_HF' `
           -replace '__CDDTYPES_H','_CDDTYPES_HF' `
           -replace 'GMPRATIONAL','ddf_GMPRATIONAL' `
           -replace 'ARITHMETIC','ddf_ARITHMETIC' `
           -replace 'CDOUBLE','ddf_CDOUBLE'
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
