#!/bin/bash

clean () {
    echo "[i] Cleaning..."
    rm -rf "build"
    rm -rf "build-debug"
}

setup () {
    if [ -z ${DEBUG} ]; then
        meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=disabled
    else
        meson setup build-debug/ --werror --buildtype=debug -Ddirect=enabled -Dsgx=disabled
    fi
}

build () {
    if [ -z ${DEBUG} ]; then
        meson compile -C build/
    else
        meson compile -C build-debug/
    fi
}

install () {
    if [ -z ${DEBUG} ]; then
        sudo meson install -C build
    else
        sudo meson install -C build-debug
    fi

    sudo ldconfig
}

if [[ "$1" == "clean" ]]; then
    clean
    exit
fi

if [ -d "build" ]; then
    echo "[i] Build dir exists, no setup needed"
else
    echo "[i] Build dir does not exist, setting up from scratch"
    setup
fi

build
install
