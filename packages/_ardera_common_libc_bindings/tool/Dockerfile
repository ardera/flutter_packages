ARG DEBIAN_FRONTEND=noninteractive

# sysroot container
FROM debian:sid as sysroot

RUN apt-get update
RUN dpkg --add-architecture armhf && \
    dpkg --add-architecture arm64 && \
    dpkg --add-architecture i386
RUN apt-get install -y libc6-dev-armhf-cross libc6-dev-arm64-cross libc6-dev-i386-cross libc6-dev-amd64-cross

# bindings generator
FROM dart:stable

COPY --from=sysroot /usr/arm-linux-gnueabihf/ /tmp/debian-sid-arm-linux-gnueabihf
COPY --from=sysroot /usr/aarch64-linux-gnu/ /tmp/debian-sid-aarch64-linux-gnu
COPY --from=sysroot /usr/i686-linux-gnu/ /tmp/debian-sid-i686-linux-gnu
COPY --from=sysroot /usr/x86_64-linux-gnu/ /tmp/debian-sid-x86_64-linux-gnu

RUN apt-get update
RUN apt-get install -y libclang-dev

COPY . /tmp/_ardera_common_libc_bindings
WORKDIR /tmp/_ardera_common_libc_bindings
RUN dart pub get

CMD dart run tool/bindingsgenerator_entry.dart && \
    cp /tmp/_ardera_common_libc_bindings/lib/src/libc_*.g.dart /tmp/_ardera_common_libc_bindings_output/lib/src/