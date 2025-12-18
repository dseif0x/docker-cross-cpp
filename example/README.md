# Cross-Compilation Example

This example demonstrates how to use the docker-cross-cpp images to build a C++ application for multiple platforms from a single Dockerfile.

## What's Included

- `test.cpp`: A simple C++ program
- `CMakeLists.txt`: CMake build configuration
- `Dockerfile`: Multi-stage build that cross-compiles the binary
- `docker-bake.hcl`: Docker Bake configuration for building multiple platforms

## How to Use

### Building for All Platforms

Build the binary for all configured platforms:

```bash
docker buildx bake
```

This will create binaries in the `build/` directory for:
- Linux: amd64, arm64, armv7, 386, riscv64, s390x, ppc64le
- Windows: amd64, 386, arm64, armv7
- Macos: amd64, arm64

### Building for Specific Platforms

Build for a single platform:

```bash
docker buildx build --platform linux/arm64 -o build .
```

Or specify multiple platforms:

```bash
docker buildx build --platform linux/amd64,linux/arm64,windows/amd64 -o build .
```

## How It Works

The `Dockerfile` uses a multi-stage build:

1. **Build stage**: Uses the appropriate `cross-cpp` image based on `$TARGETPLATFORM`
   ```dockerfile
   FROM --platform=$BUILDPLATFORM ghcr.io/dseif0x/cross-cpp-$TARGETPLATFORM:latest AS build
   ```

2. **Copy and compile**: Copies source files and runs CMake to build the binary
   ```dockerfile
   COPY CMakeLists.txt .
   COPY test.cpp .
   RUN cmake -S . -B build && cmake --build build
   ```

3. **Extract binary**: The final stage extracts just the compiled binary

The cross-compilation toolchain is automatically configured through:
- `CMAKE_TOOLCHAIN_FILE` environment variable (pre-set in the images)
- Cross-compiler environment variables (`CC`, `CXX`, `AR`, etc.)

## Customizing for Your Project

To adapt this for your own C++ project:

1. Replace `test.cpp` and `CMakeLists.txt` with your source files
2. Update the `Dockerfile` to copy your project files
3. Modify `docker-bake.hcl` to select which platforms you need
4. Add any additional dependencies to the Dockerfile build stage

## Output

Built binaries are extracted to the `build/` directory with platform-specific paths:
```
build/
  linux_amd64/
  linux_arm64/
  windows_amd64/
  ...
```

## Notes

- The images include CMake 3.20+ and Ninja build system
- CMake toolchain files are pre-configured for each platform
- For macOS targets, you may need to adjust the SDK version in the main `docker-bake.hcl`
- Windows binaries are built with llvm-mingw and target Windows 7+
