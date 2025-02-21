# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wireplumber"
PKG_VERSION="0.4.14"
PKG_SHA256="b160424ce7c3eeeccba388726f6a448f53501d25085e5fa1bf6c690c1bcd85ea"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/pipewire/wireplumber"
PKG_URL="https://gitlab.freedesktop.org/pipewire/wireplumber/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="pipewire glib lua54 glib:host"
PKG_LONGDESC="Session / policy manager implementation for PipeWire"

PKG_MESON_OPTS_TARGET="-Dintrospection=disabled \
                       -Ddoc=disabled \
                       -Dsystem-lua=true \
                       -Delogind=disabled \
                       -Dsystemd=enabled \
                       -Dsystemd-system-service=true \
                       -Dsystemd-user-service=false \
                       -Dsystemd-system-unit-dir=/usr/lib/systemd/system \
                       -Dtests=false"

post_makeinstall_target() {
  # connect to the system bus
  sed '/^\[Service\]/a Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket' -i ${INSTALL}/usr/lib/systemd/system/wireplumber.service

  # ref https://gitlab.freedesktop.org/pipewire/wireplumber/-/commit/0da29f38181e391160fa8702623050b8544ec775
  cat > ${INSTALL}/usr/share/wireplumber/main.lua.d/89-disable-session-dbus-dependent-features.lua << EOF
alsa_monitor.properties["alsa.reserve"] = false
default_access.properties["enable-flatpak-portal"] = false
EOF

  cat > ${INSTALL}/usr/share/wireplumber/main.lua.d/89-disable-v4l2.lua << EOF
v4l2_monitor.enabled = false
EOF

  cat > ${INSTALL}/usr/share/wireplumber/bluetooth.lua.d/89-disable-session-dbus-dependent-features.lua << EOF
bluez_monitor.properties["with-logind"] = false
EOF

  cat > ${INSTALL}/usr/share/wireplumber/bluetooth.lua.d/89-disable-bluez-hfphsp-backend.lua << EOF
bluez_monitor.properties["bluez5.hfphsp-backend"] = "none"
EOF

  rm ${INSTALL}/usr/share/wireplumber/main.lua.d/50-alsa-config.lua
  cp ${PKG_DIR}/deviceprofile/50-alsa-config.lua ${INSTALL}/usr/share/wireplumber/main.lua.d/
}

post_install() {
  enable_service wireplumber.service
}
