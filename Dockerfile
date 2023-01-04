FROM ubuntu

# Install tools and system dependencies of packages
RUN apt-get update -y && apt-get install -y \
  build-essential \
  pkg-config \
  opam \
  neovim \
  sudo \
  autoconf \
  ;

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user

RUN opam init --disable-sandboxing --auto-setup

# Create a fresh opam environment without all the dependencies of opam-monorepo
RUN opam switch create bench 4.14.0
RUN opam install -y dune ocamlbuild

# Create a fresh opam environment for running opam-monorepo
RUN opam switch create opam-monorepo 4.14.0
RUN opam repository add dune-universe git+https://github.com/dune-universe/opam-overlays.git

WORKDIR /home/user
ADD --chown=user:users custom-overlays ./custom-overlays
RUN opam repository add custom-overlays ./custom-overlays

RUN opam install -y opam-monorepo ppx_sexp_conv

RUN mkdir src
WORKDIR src

# Add generated files to the current directory
ADD --chown=user:users dist ./

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

# We must be in the default switch to run the tools
RUN opam switch opam-monorepo

# Generate a file "libraries.sexp" containing a list of all the libraries which
# the project will depend on. This is a separate step from generating the dune
# file so that libraries can be selectively removed from that list if necessary.
RUN . ~/.profile && \
  dune exec --display=quiet tools/list_duniverse_libraries.exe duniverse packages.sexp tools/library-ignore-list.sexp tools/run_dune_ml.sh > libraries.sexp

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
#RUN cd duniverse/ocaml-lua/src/lua_c && tar xf lua-5.1.5.tar.gz && cd lua-5.1.5 && patch -p1 -i ../lua.patch && cd .. && mv lua-5.1.5 lua515

RUN . ~/.profile && make || true
