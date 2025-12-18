# docker-bake.hcl

variable "REGISTRY" {
  default = "ghcr.io/dseif0x"
}

variable "BUILD_PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "TARGETS" {
  default = {
    "linux-amd64" = {
      dockerfile = "Dockerfile.linux"
      triple = "x86_64-linux-gnu"
      arch = "x86_64"
      platform = "linux/amd64"
    }
    "linux-arm64" = {
      dockerfile = "Dockerfile.linux"
      triple = "aarch64-linux-gnu"
      arch = "aarch64"
      platform = "linux/arm64"
    }
    "linux-armv7" = {
      dockerfile = "Dockerfile.linux"
      triple = "arm-linux-gnueabihf"
      arch = "arm"
      platform = "linux/arm/v7"
    }
    "windows-amd64" = {
      dockerfile = "Dockerfile.windows"
      triple = "x86_64-w64-mingw32"
      arch = "x86_64"
      platform = "windows/amd64"
    }
    "darwin-arm64" = {
      dockerfile = "Dockerfile.darwin"
      triple = "arm64-apple-darwin"
      arch = "arm64"
      platform = "darwin/arm64"
      sdk = "26.1"
    }
    "darwin-amd64" = {
      dockerfile = "Dockerfile.darwin"
      triple = "x86_64-apple-darwin"
      arch = "x86_64"
      platform = "darwin/amd64"
      sdk = "26.1"
    }
  }
}

target "cross-compiler" {
  name = "${target_name}-from-${replace(build_platform, "/", "-")}"
  matrix = {
    target_name = keys(TARGETS)
    build_platform = BUILD_PLATFORMS
  }
  
  dockerfile = TARGETS[target_name].dockerfile
  tags = ["${REGISTRY}/cross-cpp:target-${target_name}"]
  platforms = [build_platform]
  
  args = {
    TARGETPLATFORM = TARGETS[target_name].platform
    CROSS_TRIPLE = TARGETS[target_name].triple
    TARGET_ARCH = TARGETS[target_name].arch
    MACOS_SDK_VERSION = try(TARGETS[target_name].sdk, "")
  }
  
  labels = {
    "com.dseif0x.target-platform" = TARGETS[target_name].platform
    "com.dseif0x.cross-triple" = TARGETS[target_name].triple
    "com.dseif0x.macos-sdk" = try(TARGETS[target_name].sdk, "")
  }
}

group "default" {
  targets = ["cross-compiler"]
}