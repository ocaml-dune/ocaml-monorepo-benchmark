# Creates a monorepo out of packages in opam and builds it with dune

FROM debian

# Enable non-free packages
RUN sed -i '/^deb/ s/$/ non-free/' /etc/apt/sources.list

# Install tools and system dependencies of packages
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  pkg-config \
  opam \
  neovim \
  sudo \
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
  wget \
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
  tmux \
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
  ;

# create a non-root user
RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV HOME=/home/user
USER user
WORKDIR $HOME

# set up opam
RUN opam init --disable-sandboxing --auto-setup

# make an opam switch for running benchmarks
RUN opam switch create bench 4.14.1
RUN opam install -y dune ocamlbuild

# make an opam switch for preparing the files for the benchmark
RUN opam switch create prepare 4.14.1
RUN opam install -y opam-monorepo ppx_sexp_conv ocamlfind ctypes ctypes-foreign re sexplib menhir camlp-streams zarith stdcompat refl

# Copy the files needed to sync the duniverse repos. This is done as a separate
# step to coping the rest of the files needed for the monorepo so that those
# files can be changed without invalidating the docker cache. Syncing the
# duniverse repos takes a long time so we want to do it as early as possible to
# make the most of caching.
RUN mkdir -p $HOME/monorepo-bench
WORKDIR $HOME/monorepo-bench
COPY --chown=user:users monorepo-bench.opam .
COPY --chown=user:users monorepo-bench.opam.locked .

# Running `opam monorepo pull` with a large package set is very likely to fail on at least
# one package in a non-deterministic manner. Repeating it several times reduces the chance
# that all attempts fail.
RUN opam monorepo pull || opam monorepo pull || opam monorepo pull

# Initialize some projects' source code
RUN . ~/.profile && cd duniverse/clangml && ./configure
RUN cd duniverse/zelus && ./configure
RUN rm -rf duniverse/magic-trace/vendor
RUN cd duniverse/cpu && autoconf && autoheader && ./configure
RUN cd duniverse/setcore && autoconf && autoheader && ./configure
RUN cd duniverse/batsat-ocaml && ./build_rust.sh

# Some packages define conflicting definitions of libraries so they must be removed for the build to succeed
RUN rm -r duniverse/coq-of-ocaml
RUN rm -r duniverse/coq

# Copy the remaininder of the files needed for the monorepo benchmark
ADD --chown=user:users . .

# Apply some custom packages to some packages
RUN bash -c 'for f in patches/*; do p=$(basename ${f%.diff}); echo Applying $p; patch -p1 -d duniverse/$p < $f; done'

# Change to the benchmarking switch to run the benchmark
RUN opam switch bench
