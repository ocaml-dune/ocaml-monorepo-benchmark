FROM ubuntu

RUN apt-get update -y && apt-get install -y build-essential pkg-config opam

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
USER user

RUN opam init --disable-sandboxing --auto-setup
RUN opam switch remove default -y
RUN opam switch create default 4.14.0
RUN opam repository add dune-universe git+https://github.com/dune-universe/opam-overlays.git

WORKDIR /home/user
RUN git clone https://github.com/tarides/opam-monorepo.git
RUN opam install -y ./opam-monorepo/opam-monorepo.opam

RUN mkdir pkg
WORKDIR pkg
COPY --chown=user:users dist/out.opam ./pkg.opam

RUN opam monorepo lock
RUN opam monorepo pull || opam monorepo pull || opam monorepo pull
