FROM debian:stable-20230522

# Enable non-free packages
RUN sed -i '/^deb/ s/$/ non-free/' /etc/apt/sources.list

# Install tools and system dependencies of packages
RUN apt-get update -y && apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  libgmp-dev \
  pkg-config \
  opam \
  wget \
  autoconf \
  cargo \
  libclang-dev \
  libglib2.0-dev \
  sudo \
  ;

# create a non-root user
RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV HOME=/home/user
USER user
WORKDIR $HOME

# set up opam
RUN opam init --disable-sandboxing --auto-setup

# make a switch with opam-monorepo and some initialization dependencies installed
RUN opam switch create assemble 4.14.1 opam-monorepo ocamlfind stdcompat ppxlib refl && opam switch assemble

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

# opam-monorepo complains if these packages are omitted from its lockfile but
# the build will fail unless we delete these directories
RUN rm -r duniverse/coq-of-ocaml
RUN rm -r duniverse/coq

# Copy the patches into the image
ADD --chown=user:users patches patches

# Apply some custom packages to some packages
RUN bash -c 'for f in patches/*; do p=$(basename ${f%.diff}); echo Applying $p; patch -p1 -d duniverse/$p < $f; done'
