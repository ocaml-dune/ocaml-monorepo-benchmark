FROM ubuntu

RUN apt-get update -y && apt-get install -y opam

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
USER user

RUN opam init --disable-sandboxing --auto-setup
RUN opam switch create 4.14.0 4.14.0

USER root
RUN apt-get install -y build-essential pkg-config
USER user

WORKDIR /home/user
RUN git clone https://github.com/tarides/opam-monorepo.git
RUN opam install -y ./opam-monorepo/opam-monorepo.opam

RUN mkdir pkg
WORKDIR pkg

COPY --chown=user:users dist/out.opam ./pkg.opam
