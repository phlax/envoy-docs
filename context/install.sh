#!/bin/bash -e


function download_and_check () {
  local to=$1
  local url=$2
  local sha256=$3

  curl -fsSL --output "${to}" "${url}"
  echo "${sha256}  ${to}" | sha256sum --check
}

# buildifier
VERSION=2.2.1
download_and_check /usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/"$VERSION"/buildifier \
		   731a6a9bf8fca8a00a165cd5b3fbac9907a7cf422ec9c2f206b0a76c0a7e3d62
chmod +x /usr/local/bin/buildifier

# buildozer
VERSION=2.2.1
download_and_check /usr/local/bin/buildozer https://github.com/bazelbuild/buildtools/releases/download/"$VERSION"/buildozer \
		   5aa4f70f5f04599da2bb5b7e6a46af3e323a3a744c11d7802517d956909633ae
chmod +x /usr/local/bin/buildozer

# bazelisk
VERSION=1.3.0
download_and_check /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v${VERSION}/bazelisk-linux-amd64 \
		   98af93c6781156ff3dd36fa06ba6b6c0a529595abb02c569c99763203f3964cc
chmod +x /usr/local/bin/bazel

LLVM_VERSION=10.0.0
LLVM_DISTRO=x86_64-linux-gnu-ubuntu-18.04
LLVM_SHA256SUM=b25f592a0c00686f03e3b7db68ca6dc87418f681f4ead4df4745a01d9be63843

LLVM_RELEASE="clang+llvm-${LLVM_VERSION}-${LLVM_DISTRO}"
LLVM_DOWNLOAD_PREFIX=${LLVM_DOWNLOAD_PREFIX:-https://github.com/llvm/llvm-project/releases/download/llvmorg-}
download_and_check "${LLVM_RELEASE}.tar.xz" "${LLVM_DOWNLOAD_PREFIX}${LLVM_VERSION}/${LLVM_RELEASE}.tar.xz" "${LLVM_SHA256SUM}"
tar Jxf "${LLVM_RELEASE}.tar.xz"
mv "./${LLVM_RELEASE}" /opt/llvm
chown -R root:root /opt/llvm
rm "./${LLVM_RELEASE}.tar.xz"
echo "/opt/llvm/lib" > /etc/ld.so.conf.d/llvm.conf
ldconfig


# Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
  | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -


apt-get update -y
apt-get install -y --no-install-recommends aspell wget make cmake git \
  unzip bc libtool automake zip time gdb strace patch xz-utils rsync ssh-client \
  google-cloud-sdk libncurses-dev doxygen graphviz bzip2 sudo


# MSAN
export PATH="/opt/llvm/bin:${PATH}"

WORKDIR=$(mktemp -d)
function cleanup {
  rm -rf "${WORKDIR}"
}

trap cleanup EXIT

cd "${WORKDIR}"

curl -sSfL "https://github.com/llvm/llvm-project/archive/llvmorg-${LLVM_VERSION}.tar.gz" | tar zx

mkdir msan
pushd msan

cmake -GNinja -DLLVM_ENABLE_PROJECTS="libcxxabi;libcxx" -DLLVM_USE_LINKER=lld -DLLVM_USE_SANITIZER=Memory -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX="/opt/libcxx_msan" "../llvm-project-llvmorg-${LLVM_VERSION}/llvm"
ninja install-cxx install-cxxabi

if [[ ! -z "$(diff -r /opt/libcxx_msan/include/c++ /opt/llvm/include/c++)" ]]; then
  echo "Different libc++ is installed";
  exit 1
fi

rm -rf /opt/libcxx_msan/include

popd

mkdir tsan
pushd tsan

cmake -GNinja -DLLVM_ENABLE_PROJECTS="libcxxabi;libcxx" -DLLVM_USE_LINKER=lld -DLLVM_USE_SANITIZER=Thread -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX="/opt/libcxx_tsan" "../llvm-project-llvmorg-${LLVM_VERSION}/llvm"
ninja install-cxx install-cxxabi

rm -rf /opt/libcxx_tsan/include

popd
