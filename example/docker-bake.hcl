target "platforms" {
    platforms = [
        "linux/amd64",
        "linux/arm64",
        "linux/arm/v7",
        "linux/s390x",
        "linux/ppc64le",
        "linux/386",
        "linux/riscv64",
        "darwin/amd64",
        "darwin/arm64",
        "windows/amd64",
        "windows/386",
        "windows/arm64",
        "windows/arm/v7"
    ]
}

group "default" {
    targets = ["binary"]
}


target "binary" {
    inherits = ["platforms"]
    output = ["build"]
}