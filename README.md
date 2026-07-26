# docker-cross-cpp

Docker images for cross-compiling C++ applications to multiple platforms from amd64/arm64 host architectures.

## What It Does

This project provides pre-built Docker images containing cross-compilation toolchains for building C++ binaries targeting Linux, Windows, and macOS platforms across various architectures. The images are designed to work seamlessly with Docker BuildKit's multi-platform build capabilities.

## How It Works

The project builds specialized Docker images for each target platform:
- **Linux targets**: Uses GCC cross-compilation toolchains for amd64, arm64, armv7, riscv64, 386, s390x, and ppc64le
- **Windows targets**: Uses llvm-mingw for amd64, 386, arm64, and armv7
- **macOS targets**: Uses OSXCross for amd64 and arm64
- **iOS targets**: Uses clang with the iOS SDK and OSXCross cctools (ld64) for arm64

Each image includes:
- Cross-compilation toolchain
- CMake with pre-configured toolchain files
- Environment variables set for cross-compilation
- Build tools (ninja, cmake)

## Quick Start

Use the images in your Dockerfile with Docker's `TARGETPLATFORM` variable:

```dockerfile
FROM --platform=$BUILDPLATFORM ghcr.io/dseif0x/cross-cpp-$TARGETPLATFORM:latest AS build
```

This automatically selects the correct cross-compiler image based on your target platform.

## Available Images

Images are published to `ghcr.io/dseif0x/cross-cpp-<platform>:latest` for the following platforms:

- `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- `linux/riscv64`, `linux/386`, `linux/s390x`, `linux/ppc64le`
- `windows/amd64`, `windows/386`, `windows/arm64`, `windows/arm/v7`
- `darwin/amd64`, `darwin/arm64`
- `ios/arm64`

## Examples

- [example/](example/) – builds a simple C++ binary for multiple platforms.
- [example-linux-kernel/](example-linux-kernel/) – cross-compiles the Linux kernel for multiple architectures. The kernel source is shallow-cloned at build time and is not stored in this repository.

## Building the Images

To build all cross-compiler images:

```bash
docker buildx bake
```

To build specific targets:

```bash
docker buildx bake linux-amd64 windows-amd64 darwin-arm64
```

## License

See LICENSE file for details.
