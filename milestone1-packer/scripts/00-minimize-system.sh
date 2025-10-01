#!/bin/bash
# System minimization script - removes unnecessary packages to create minimal install

set -euo pipefail

echo "Starting system minimization..."

# Remove unnecessary packages to create minimal install
dnf remove -y \
    alsa-* \
    atk \
    at-spi2-* \
    avahi-* \
    bluetooth \
    bluez-* \
    cups-* \
    desktop-file-utils \
    fprintd \
    gdm \
    gnome-* \
    gtk3 \
    ibus-* \
    libX11-* \
    libXcomposite \
    libXcursor \
    libXdamage \
    libXext \
    libXfixes \
    libXi \
    libXinerama \
    libXrandr \
    libXrender \
    libXScrnSaver \
    libXtst \
    mesa-* \
    NetworkManager-* \
    plymouth-* \
    pulseaudio-* \
    qt5-* \
    qt6-* \
    samba-* \
    sound-theme-* \
    xorg-* \
    yelp \
    || true

# Remove development tools if not needed
dnf remove -y \
    gcc \
    gcc-c++ \
    make \
    kernel-devel \
    kernel-headers \
    || true

# Remove documentation
dnf remove -y \
    man-pages \
    || true

# Clean up package cache
dnf clean all

# Remove unnecessary files
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/locale/*/LC_MESSAGES/*.mo

echo "System minimization completed"

