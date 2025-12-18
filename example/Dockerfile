FROM --platform=$BUILDPLATFORM ghcr.io/dseif0x/cross-cpp-$TARGETPLATFORM:latest AS build 
COPY CMakeLists.txt .
COPY test.cpp .
RUN cmake -S . -B build && cmake --build build
RUN mv build/test_binary* /

FROM scratch
COPY --from=build /test_binary* /