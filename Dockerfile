FROM ubuntu

# Install tools and system dependencies of packages
RUN apt-get update -y && apt-get install -y \
  build-essential \
  pkg-config \
  opam \
  neovim \
  sudo \
  autoconf \
  zlib1g-dev \
  libcairo2-dev \
  libcurl4-gnutls-dev \
  ;

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user
WORKDIR /home/user

ADD --chown=user:users data/repos/opam-repository ./opam-repository
RUN opam init --disable-sandboxing --auto-setup ./opam-repository

# Create a fresh opam environment without all the dependencies of opam-monorepo
RUN opam switch create bench 4.14.0
RUN opam install -y dune ocamlbuild

# Create a fresh opam environment for running opam-monorepo
RUN opam switch create opam-monorepo 4.14.0

RUN git clone https://github.com/tarides/opam-monorepo.git
RUN cd opam-monorepo && git checkout 0.3.5
RUN opam install -y ./opam-monorepo/opam-monorepo.opam ppx_sexp_conv

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

RUN opam install -y re sexplib

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

RUN . ~/.profile && make || true
