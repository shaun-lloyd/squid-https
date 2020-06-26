#!/bin/sh
#
## Copyright (C) 1996-2020 The Squid Software Foundation and contributors
##
## Squid software is distributed under GPLv2+ license and includes
## contributions from numerous individuals and organizations.
## Please see the COPYING and CONTRIBUTORS files for details.
##

# test all header files (.h) for dependancy issues.
#
# Ideally this test should be performed twice before any code is accepted.
# With or without inline enabled.  This is needed because the .cci files
#  are only included into the .h files when inline mode is enabled.
#
# This script should be run from the makefile with the directory path and ccflags
#
cc="${1}"
shift
for dir in /usr/bin /usr/local/bin /usr/gnu/bin
do
	test -x ${dir}/true && TRUE=${dir}/true
done
TRUE=${TRUE:-/bin/true}

exitCode=0

for f in $@; do
	echo -n "Testing ${f} ..."
    t="testhdr_`basename ${f}`"
    if [ ! -f "$t.o" -o $f -nt "$t.o" ]; then
        echo >$t.cc <<EOF
/* This file is AUTOMATICALLY GENERATED. DO NOT ALTER IT */
#include "squid.h"
#include "${f}"
int main( int argc, char* argv[] ) { return 0; }
EOF
        if ${cc} -c -o $t.o $t.cc ; then 
            echo "Ok."
        else
            echo "Fail."
            exitCode=1
        fi
        rm $t.cc $t.o
    fi
    test $exitCode -eq 0 || break
done

#who ever said that the test program needs to be meaningful?
test $exitCode -eq 0 && cp ${TRUE} testHeaders
exit $exitCode