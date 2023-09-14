FROM debian:stable-20230522

# Enable non-free packages
RUN sed -i '/^deb/ s/$/ non-free/' /etc/apt/sources.list

# Install tools and system dependencies of packages
RUN apt-get update -y && apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  sudo \
  pkg-config \
  opam \
  wget \
  autoconf \
  zlib1g-dev \
  libcairo2-dev \
  libcurl4-gnutls-dev \
  libsnmp-dev \
  libgmp-dev \
  libbluetooth-dev \
  cmake \
  libfarmhash-dev \
  libgl-dev \
  libnlopt-dev \
  libmpfr-dev \
  r-base-core \
  libjemalloc-dev \
  libsnappy-dev \
  libpapi-dev \
  libgles2 \
  libgles2-mesa-dev \
  fswatch \
  librdkafka-dev \
  google-perftools \
  libgoogle-perftools-dev \
  libglew-dev \
  guile-3.0-dev \
  portaudio19-dev \
  libglpk-dev \
  libportmidi-dev \
  libmpg123-dev \
  libgtksourceview-3.0-dev \
  libhidapi-dev \
  libfftw3-dev \
  libasound2-dev \
  libzmq3-dev \
  r-base-dev \
  libgtk2.0-dev \
  libsoundtouch-dev \
  libmp3lame-dev \
  libplplot-dev \
  libogg-dev \
  libavutil-dev \
  libavfilter-dev \
  libswresample-dev \
  libavcodec-dev \
  libfdk-aac-dev \
  libfaad2 \
  libsamplerate0-dev \
  libao-dev \
  liblmdb-dev \
  libnl-3-dev \
  libnl-route-3-dev \
  sqlite3 \
  libsqlite3-dev \
  cargo \
  libtool \
  libopenimageio-dev \
  libtidy-dev \
  libleveldb-dev \
  libgtkspell-dev \
  libtag1-dev \
  libsrt-openssl-dev \
  liblo-dev \
  libmad0-dev \
  frei0r-plugins-dev \
  libavdevice-dev \
  libfaad-dev \
  libglfw3-dev \
  protobuf-compiler \
  libuv1-dev \
  libxen-dev \
  libflac-dev \
  libpq-dev \
  libtheora-dev \
  libonig-dev \
  libglib2.0-dev \
  libgoocanvas-2.0-dev \
  libgtkspell3-3-dev \
  libpulse-dev \
  libdlm-dev \
  capnproto \
  libtorch-dev \
  libqrencode-dev \
  libshine-dev \
  libopus-dev \
  libspeex-dev \
  libvorbis-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  liblz4-dev \
  liblilv-dev \
  libopenexr-dev \
  llvm \
  libclang-dev \
  libmaxminddb-dev \
  libsecp256k1-dev \
  libstring-shellquote-perl \
  libopenblas-dev \
  qt5-qmake \
  libqt5quick5 \
  qtdeclarative5-dev \
  libgpiod-dev \
  libzstd-dev \
  neovim \
  tmux \
  ;

# create a non-root user
RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV HOME=/home/user
USER user
WORKDIR $HOME

# set up opam
RUN opam init --disable-sandboxing --auto-setup

# make a switch for running the benchmarks
RUN opam switch create bench 4.14.1 dune ocamlbuild

# copy the directories containing the benchmark and benchmark runner
ADD --chown=user:users benchmark benchmark
ADD --chown=user:users dune-monorepo-benchmark-runner/src dune-monorepo-benchmark-runner/src
ADD --chown=user:users dune-monorepo-benchmark-runner/dune-monorepo-benchmark-runner.opam dune-monorepo-benchmark-runner/dune-monorepo-benchmark-runner.opam
ADD --chown=user:users dune-monorepo-benchmark-runner/dune-project dune-monorepo-benchmark-runner/dune-project

RUN opam install -y ./dune-monorepo-benchmark-runner
WORKDIR $HOME/benchmark
