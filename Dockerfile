# Dockerfile to build wlroots and dwl.

FROM debian:sid

RUN mkdir /artifacts

RUN apt-get update
RUN apt-get install -y \
    cmake \
    git \
    meson \
    pkgconf \
    glslang-tools \
    hwdata \
    libcairo2-dev \
    libdisplay-info-dev \
    libdrm-dev \
    libegl-dev \
    libgbm-dev \
    libgles-dev \
    libinput-dev \
    liblcms2-dev \
    libliftoff-dev \
    libpixman-1-dev \
    libseat-dev \
    libudev-dev \
    libvulkan-dev \
    libwayland-dev \
    libxcb-composite0-dev \
    libxcb-dri3-dev \
    libxcb-errors-dev \
    libxcb-ewmh-dev \
    libxcb-icccm4-dev \
    libxcb-present-dev \
    libxcb-render-util0-dev \
    libxcb-res0-dev \
    libxcb-shm0-dev \
    libxcb-xinput-dev \
    libxkbcommon-dev \
    wayland-protocols \
    xwayland

# Use `docker build --build-arg NEW_WLTOORS=$(date +%s)` to force rebuild from here.
ARG NEW_ALL=date

# Build wlroots.
WORKDIR /root
RUN git clone --depth 1 --branch 0.19.0 https://gitlab.freedesktop.org/wlroots/wlroots.git
WORKDIR /root/wlroots
RUN meson setup build/
RUN ninja -C build/ install

RUN cp -a --parents \
    /usr/local/include/wlroots* \
    /usr/local/lib/x86_64-linux-gnu/libwlroots-0.19.so \
    /artifacts/.

# Use `docker build --build-arg NEW_DWL=$(date +%s)` to force rebuild from here.
ARG NEW_DWL=date
# Build dwl.
WORKDIR /root
RUN git clone --depth 1 --branch master https://github.com/israellevin/dwl.git
WORKDIR /root/dwl
RUN make install

RUN cp -a --parents \
    /usr/local/bin/dwl \
    /usr/local/share/man/man1/dwl.1 \
    /usr/local/share/wayland-sessions/dwl.desktop \
    /artifacts/.

# Build dwlmsg.
WORKDIR /root
RUN git clone --depth 1 --branch main https://codeberg.org/notchoc/dwlmsg.git
WORKDIR /root/dwlmsg
RUN make CFLAGS='-std=gnu17' install

RUN cp -a --parents \
    /usr/local/bin/dwlmsg \
    /artifacts/.

# Serve the artifacts directory all tarred up.
RUN apt install -y netcat-openbsd
EXPOSE 8000
CMD sh -c '( \
    printf "HTTP/1.0 200 OK\r\nContent-Type: application/x-tar\r\n\r\n"; \
    tar -C /artifacts -cf - . \; \
    echo \
) | nc -lp8000 -q0'
