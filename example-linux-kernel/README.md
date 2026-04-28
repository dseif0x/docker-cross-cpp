# Linux Kernel Cross-Compilation Example

This example demonstrates how to cross-compile the Linux kernel for multiple
architectures using the docker-cross-cpp images.

The kernel source is **not** included in this repository. The `Dockerfile`
performs a shallow `git clone` of the official Linux kernel repository at
build time, so the source is never stored locally.

## What's Included

- `Dockerfile`: Multi-stage build that shallow-clones the kernel source and
  cross-compiles it for the target architecture.
- `docker-bake.hcl`: Docker Bake configuration for building all supported
  Linux platforms.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with
  [BuildKit](https://docs.docker.com/buildx/working-with-buildx/) enabled
- `docker buildx` available (bundled with Docker Desktop / Docker Engine ≥ 23)

> **Note**: Building the Linux kernel is CPU- and memory-intensive. Allow
> 10–30 minutes per architecture and at least 4 GB of RAM per parallel build.

## How to Use

### Building for All Platforms

```bash
docker buildx bake
```

This builds the kernel for all configured Linux platforms:

| Docker platform   | Kernel `ARCH` | Output image          |
|-------------------|---------------|-----------------------|
| `linux/amd64`     | `x86_64`      | `arch/x86/boot/bzImage`   |
| `linux/arm64`     | `arm64`       | `arch/arm64/boot/Image`   |
| `linux/arm/v7`    | `arm`         | `arch/arm/boot/zImage`    |
| `linux/riscv64`   | `riscv`       | `arch/riscv/boot/Image`   |
| `linux/386`       | `x86`         | `arch/x86/boot/bzImage`   |
| `linux/s390x`     | `s390`        | `arch/s390/boot/bzImage`  |
| `linux/ppc64le`   | `powerpc`     | `vmlinux`                 |

Built kernel images are placed under the `build/` directory, one
subdirectory per platform:

```
build/
  linux_amd64/
    kernel-image
  linux_arm64/
    kernel-image
  ...
```

### Building for a Single Platform

```bash
docker buildx build --platform linux/arm64 -o build .
```

### Selecting a Different Kernel Version

Pass `KERNEL_VERSION` as a build argument to choose any tag from the
[Linux kernel repository](https://github.com/torvalds/linux):

```bash
docker buildx bake --set linux-kernel.args.KERNEL_VERSION=v6.12
```

Or when building directly:

```bash
docker buildx build --platform linux/arm64 \
  --build-arg KERNEL_VERSION=v6.12 \
  -o build .
```

## How It Works

The `Dockerfile` uses a two-stage build:

1. **Build stage** – starts from the appropriate `cross-cpp` image for the
   target platform:
   ```dockerfile
   FROM --platform=$BUILDPLATFORM ghcr.io/dseif0x/cross-cpp-$TARGETPLATFORM:latest AS build
   ```
   Additional kernel build tools (`git`, `bc`, `flex`, `bison`, `libssl-dev`,
   `libelf-dev`, `make`) are installed on top.

2. **Shallow clone** – fetches only the tip of the requested kernel tag to
   avoid downloading the full git history:
   ```dockerfile
   ARG KERNEL_VERSION=v6.6
   RUN git clone --depth=1 --branch ${KERNEL_VERSION} \
       https://github.com/torvalds/linux.git /linux
   ```

3. **Cross-compile** – maps the Docker `TARGETARCH` build arg to the kernel
   `ARCH` variable and derives `CROSS_COMPILE` from the `CC` environment
   variable pre-set in the cross-cpp image:
   ```dockerfile
   RUN case "${TARGETARCH}" in \
       amd64) KERNEL_ARCH=x86_64 ; ... ;; \
       ...
       esac && \
       CROSS_COMPILE="${CC%gcc}" && \
       make ARCH=${KERNEL_ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig && \
       make ARCH=${KERNEL_ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)
   ```

4. **Extract** – the final `FROM scratch` stage copies only the compiled
   kernel image so the output is minimal.

## Notes

- The default kernel version is **v6.6** (a long-term stable release).
- `make defconfig` is used to generate a sensible default configuration for
  each architecture. Replace it with your own `.config` or a custom config
  target if needed.
- Windows and macOS platforms are intentionally excluded because the Linux
  kernel only targets Linux.
