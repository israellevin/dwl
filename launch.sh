#!/usr/bin/sh
LIBSEAT_BACKEND=seatd
XDG_RUNTIME_DIR="/run/user/$(id -u)"

export XDG_RUNTIME_DIR
export LIBSEAT_BACKEND

/usr/libexec/xdg-desktop-portal-wlr -r &
/usr/libexec/xdg-desktop-portal -r &

exec dwl -s ' \
    red & \
    foot & \
    brows & \
    clip --start & \
    wait'
