#!/bin/bash

set -ex

# remove test failing in non interactive shell
rm ext/standard/tests/file/lstat_stat_variation10.phpt
rm ext/standard/tests/network/bug73594.phpt

# skip flaky test at TravisCI
# https://github.com/php/php-src/blob/b9f4fb8aefaeb3802d6f79f6aad7029b63e488a2/ext/standard/tests/file/disk_free_space_basic.phpt#L5
if [[ "$CI" == "travis" ]]; then
    export TRAVIS="true"
fi

if [[ "${target_platform}" == linux-* ]]; then
    OPCACHE_FLAG="--enable-opcache"
else
    OPCACHE_FLAG="--disable-opcache"
fi

./configure --prefix="${PREFIX}" \
            --with-iconv="${PREFIX}" \
            --with-openssl="${PREFIX}" \
            --with-libxml-dir="${PREFIX}" \
            --with-external-pcre \
            ${OPCACHE_FLAG}

make -j"${CPU_COUNT}"

export NO_INTERACTION=1
if [[ "${target_platform}" == "linux-"* ]]; then
    script -ec "make test"
else
    export SKIP_IO_CAPTURE_TESTS=1
    make test
fi

make install
