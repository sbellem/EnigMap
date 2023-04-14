FROM python:3.11 as base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
                build-essential \
                clang \
                clang-13 \
                clang-format \
                clang-format-13 \
                cmake \
                cppcheck \
                doxygen \
                gcovr \
                gdb \
                git \
                libboost-dev \
                libc++-13-dev \
                libc++abi-13-dev \
                libgtest-dev \
                libssl-dev \
                lcov \
                #lld \
                #make \
                ninja-build \
                #python3 \
                #python3-pip \
                #python-is-python3 \
                unzip \
                vim \
                wget \
        && rm -rf /var/lib/apt/lists/*

RUN wget "https://github.com/boyter/scc/releases/download/v3.0.0/scc-3.0.0-x86_64-unknown-linux.zip"
RUN unzip "scc-3.0.0-x86_64-unknown-linux.zip" -d /
RUN chmod +x /scc

RUN python -m pip install cppcheck-codequality matplotlib numpy

# C++ SGX SDK (linux-sgx)
COPY --from=initc3/linux-sgx:2.15.1-ubuntu20.04 /opt/sgxsdk /opt/sgxsdk
COPY --from=initc3/linux-sgx:2.15.1-ubuntu20.04 \
                /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 \
                /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1

RUN set -eux; \
        echo 'source /opt/sgxsdk/environment' >> /root/.bashrc;

WORKDIR /usr/src/enigmap

COPY applications applications
COPY cmake cmake
COPY ods ods
COPY tests tests
COPY CMakeLists.txt .


FROM base as build

ARG cc=/usr/bin/clang
ARG cxx=/usr/bin/clang++
ARG cmake_build_type=Release
ENV CC ${cc}
ENV CXX ${cxx}

RUN cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=${cmake_build_type}
RUN ninja -C build
