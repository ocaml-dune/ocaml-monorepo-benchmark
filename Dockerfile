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
  ;

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user
WORKDIR /home/user

ADD --chown=user:users data/repos/opam-repository ./opam-repository
RUN opam init --disable-sandboxing --auto-setup ./opam-repository

# Create a fresh opam environment without all the dependencies of opam-monorepo
RUN opam switch create bench 4.14.1
RUN opam install -y dune ocamlbuild

# Create a fresh opam environment for installing dependencies
RUN opam switch create prepare 4.14.1

RUN opam install -y opam-monorepo ppx_sexp_conv ocamlfind ctypes ctypes-foreign re sexplib menhir camlp-streams zarith

ADD --chown=user:users custom-overlays ./custom-overlays
ADD --chown=user:users data/repos/opam-overlays ./dune-duniverse
RUN rm -rf ./dune-duniverse/.git
RUN opam repository add custom-overlays ./custom-overlays
RUN opam repository add dune-universe ./dune-duniverse

RUN mkdir src
WORKDIR src

# Add generated files to the current directory
ADD --chown=user:users dist ./
ADD --chown=user:users opam_monorepo_binary_search.sh ./
RUN ./opam_monorepo_binary_search.sh < packages

# Generate the lockfile
RUN opam monorepo lock

# Running `opam monorepo pull` with a large package set is very likely to fail on at least
# one package in a non-deterministic manner. Repeating it several times reduces the chance
# that all attempts fail.
RUN opam monorepo pull || opam monorepo pull || opam monorepo pull

# Copy the benchmarking project into the docker image, including the tools
# required for generating the remainder of the project
ADD --chown=user:users bench-proj ./

# Some packages assume they are being built inside a git repo
RUN  git config --global user.email "you@example.com" && \
 git config --global user.name "Your Name"

# Initialize the top-level dune file to ignore duniverse, so that the tools can
# be built and run without needing to build all of duniverse
RUN echo '(dirs tools vendored)' > dune

# Generate a file "libraries.sexp" containing a list of all the libraries which
# the project will depend on. This is a separate step from generating the dune
# file so that libraries can be selectively removed from that list if necessary.
RUN . ~/.profile && \
  dune exec --display=quiet tools/list_duniverse_libraries.exe duniverse packages tools/library-ignore-list.sexp tools/run_dune_ml.sh > libraries.sexp

# Generate the dune file. Temporarily create dune.new and then move it over dune
# as we need to continue ignoring the duniverse dir by means of the current dune
# file in order to run the tool which will generate the eventual dune file.
RUN . ~/.profile && \
  dune exec ./tools/dune_of_sexp.exe < libraries.sexp > dune.new
RUN mv dune.new dune

# Prepare native sources for hacl-star
RUN . ~/.profile && cd duniverse/hacl-star/raw && ./configure && make -j

# Prepare why3
RUN . ~/.profile && \
  cd duniverse/why3 && \
  ./autogen.sh && \
  ./configure && \
  make coq.dune pvs.dune isabelle.dune src/util/config.ml

# Install camlp5 outside of opam
RUN . ~/.profile && \
  mkdir -p ~/.local && \
  cd duniverse/camlp5 && \
  ./configure --prefix /home/user/.local && \
  make -j && \
  make install

# Prepare coq
RUN . ~/.profile && cd duniverse/coq && ./configure -no-ask

# TODO
RUN opam install -y stdcompat refl
RUN sudo apt-get install -y \
  llvm \
  libclang-dev \
  ;

RUN . ~/.profile && cd duniverse/clangml && ./configure

# Change to the benchmarking switch to run the benchmark
RUN opam switch bench

# Apply some custom packages to some packages
RUN mkdir -p patches
COPY --chown=user:users patches/* ./patches/
RUN bash -c 'for f in patches/*; do p=$(basename ${f%.diff}); echo Applying $p; patch -p1 -d duniverse/$p < $f; done'

RUN cd duniverse/zelus && ./configure

RUN rm -rf duniverse/magic-trace/vendor

RUN cd duniverse/ocurl && ./configure

RUN cd duniverse/elpi && make config LEGACY_PARSER=1

RUN cd duniverse/cpu && autoconf && autoheader && ./configure

RUN cd duniverse/setcore && autoconf && autoheader && ./configure

RUN cd duniverse/batsat-ocaml && ./build_rust.sh

# This is a hack to make hacl-star compile on aarch64 and x64.
# Different raw files get built depending on the architecture,
# and we want to depend on all available .ml files in the raw
# library.
RUN bash -c 'TARGETS=$(cd duniverse/hacl-star/raw/lib && ls *.ml | xargs); sed -i -e "s/__TARGETS__/$TARGETS/" duniverse/hacl-star/dune'

# async_ssl currently doesn't compile and is an optional dependency of some other packages
# that we want to build, so we have to delete it
RUN rm -r duniverse/async_ssl
RUN rm -r duniverse/coq-of-ocaml

RUN . ~/.profile && make || true
