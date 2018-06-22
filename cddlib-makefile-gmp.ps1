# to be kept in sync with SED_GMP from cddlib/lib-src/Makefile.gmp.am

function MakeGmp {
    param( [string]$InFile, [string]$OutFile )
    (Get-Content $InFile) | 
    Foreach-Object {
        $_ -replace 'dd_','ddf_'
        $_ -replace 'cddf_','cdd_'
        $_ -replace 'mytype','myfloat'
        $_ -replace '#include "cdd.h"','#include "cdd_f.h"'
        $_ -replace '#include "cddtypes.h"','#include "cddtypes_f.h'
        $_ -replace '#include "cddmp.h"','#include "cddmp_f.h'
        $_ -replace '__CDD_H','__CDD_HF'
        $_ -replace '__CDD_HFF','__CDD_HF'
        $_ -replace '__CDDMP_H','_CDDMP_HF'
        $_ -replace '__CDDTYPES_H','_CDDTYPES_HF'
        $_ -replace 'GMPRATIONAL','ddf_GMPRATIONAL'
        $_ -replace 'ARITHMETIC','ddf_ARITHMETIC'
        $_ -replace 'CDOUBLE','ddf_CDOUBLE'
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
