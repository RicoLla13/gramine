#!/bin/bash

clean () {
    echo "[i] Cleaning..."
    rm -rf "build"
}

setup () {
    meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=disabled
}

build () {
    meson compile -C build/
}

install () {
    sudo meson install -C build
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
