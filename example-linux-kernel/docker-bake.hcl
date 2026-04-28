target "linux-platforms" {
    platforms = [
        "linux/amd64",
        "linux/arm64",
        "linux/arm/v7",
        "linux/s390x",
        "linux/ppc64le",
        "linux/386",
        "linux/riscv64",
    ]
}

group "default" {
    targets = ["linux-kernel"]
}

target "linux-kernel" {
    inherits = ["linux-platforms"]
    output   = ["build"]

    args = {
        KERNEL_VERSION = "v7.0"
    }
}
