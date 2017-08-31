#!/bin/bash
set -e

yum install -y gettext gcc autoconf libtool automake make asciidoc xmlto udns-devel libev-devel

export LIBSODIUM_VER=1.0.12
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
make install
popd
ldconfig

export MBEDTLS_VER=2.4.2
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
make DESTDIR=/usr install
popd
ldconfig

export SHADOWSOCKS_VER=3.0.5
wget https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SHADOWSOCKS_VER/shadowsocks-libev-$SHADOWSOCKS_VER.tar.gz
tar xvf shadowsocks-libev-$SHADOWSOCKS_VER.tar.gz
pushd shadowsocks-libev-$SHADOWSOCKS_VER
sed -i 's/MAX_CONNECT_TIMEOUT 10/MAX_CONNECT_TIMEOUT 86400/g' src/jconf.h
./configure
make
make install
popd


