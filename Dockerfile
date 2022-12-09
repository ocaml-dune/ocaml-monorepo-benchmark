FROM ubuntu

RUN apt-get update -y && apt-get install -y \
  build-essential \
  pkg-config \
  opam \
  neovim \
  libipc-system-simple-perl \
  libstring-shellquote-perl \
  curl \
  sudo \
  libasound2-dev \
  ;

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user

RUN opam init --disable-sandboxing --auto-setup
RUN opam switch remove default -y
RUN opam switch create default 4.14.0
RUN opam repository add dune-universe git+https://github.com/dune-universe/opam-overlays.git

WORKDIR /home/user
RUN git clone https://github.com/tarides/opam-monorepo.git
RUN opam install -y ./opam-monorepo/opam-monorepo.opam
RUN opam install -y ppx_sexp_conv

RUN mkdir pkg
WORKDIR pkg

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

# Initialize the top-level dune file to ignore duniverse, so that the tools can
# be built and run without needing to build all of duniverse
RUN echo '(dirs tools vendored)' > dune

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

# Recreate the opam environment without all the dependencies of opam-monorepo
RUN opam switch remove default -y
RUN opam switch create default 4.14.0
RUN opam install -y dune camlp5 tiny_json
