FROM --platform=$BUILDPLATFORM ghcr.io/dseif0x/cross-cpp-$TARGETPLATFORM:latest AS build

# Install Linux kernel build dependencies
RUN apt-get update && apt-get install -y \
    git \
    bc \
    flex \
    bison \
    libssl-dev \
    libelf-dev \
    make \
    && rm -rf /var/lib/apt/lists/*

# Shallow clone the Linux kernel at the specified version tag
ARG KERNEL_VERSION=v6.6
RUN git clone --depth=1 --branch ${KERNEL_VERSION} \
    https://github.com/torvalds/linux.git /linux

WORKDIR /linux

# Pre-defined Docker build args for the target platform
ARG TARGETARCH
ARG TARGETVARIANT

# Map Docker TARGETARCH to the Linux kernel ARCH name, derive CROSS_COMPILE
# from the CC environment variable set by the cross-cpp image, then build.
RUN case "${TARGETARCH}" in \
    amd64)   KERNEL_ARCH=x86_64  ; KERNEL_IMAGE=arch/x86/boot/bzImage   ;; \
    arm64)   KERNEL_ARCH=arm64   ; KERNEL_IMAGE=arch/arm64/boot/Image    ;; \
    arm)     KERNEL_ARCH=arm     ; KERNEL_IMAGE=arch/arm/boot/zImage     ;; \
    riscv64) KERNEL_ARCH=riscv   ; KERNEL_IMAGE=arch/riscv/boot/Image    ;; \
    386)     KERNEL_ARCH=x86     ; KERNEL_IMAGE=arch/x86/boot/bzImage    ;; \
    s390x)   KERNEL_ARCH=s390    ; KERNEL_IMAGE=arch/s390/boot/bzImage   ;; \
    ppc64le) KERNEL_ARCH=powerpc ; KERNEL_IMAGE=vmlinux                  ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    CROSS_COMPILE="${CC%gcc}" && \
    make ARCH=${KERNEL_ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig && \
    make ARCH=${KERNEL_ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc) && \
    cp ${KERNEL_IMAGE} /kernel-image

FROM scratch
COPY --from=build /kernel-image /kernel-image
