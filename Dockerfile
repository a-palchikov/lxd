# syntax = docker/dockerfile:1.2

ARG GO_VERSION=1.16.5-buster

FROM golang:${GO_VERSION} AS gobase
RUN --mount=target=/root/.cache,type=cache --mount=target=/go/pkg/mod,type=cache \
	set -ex && \
	apt update && apt --no-install-recommends -y install \
		build-essential \
		autotools-dev dh-autoreconf \
		liblz4-dev libsqlite3-dev libuv1-dev libcap-dev libacl1-dev libudev-dev lxc-dev

FROM gobase AS builder
WORKDIR /host
ENV GOFLAGS="-mod=vendor"
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-I/go/deps/raft/include/ -I/go/deps/dqlite/include/"
ENV CGO_LDFLAGS="-L/go/deps/raft/.libs -L/go/deps/dqlite/.libs/"
ENV LD_LIBRARY_PATH="/go/deps/raft/.libs/:/go/deps/dqlite/.libs/"
ENV CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)"
RUN --mount=target=/host --mount=target=/go/deps,type=cache --mount=target=/root/.cache,type=cache --mount=target=/go/pkg/mod,type=cache \
	set -ex && \
	make deps && make && \
	cp --archive /go/deps/raft/.libs/libraft.so.0.0.7 /go/bin && \
	cp --archive /go/deps/dqlite/.libs/libdqlite.so.0.0.1 /go/bin && \
	cp --archive /usr/lib/x86_64-linux-gnu/liblxc.so.1.4.0 /go/bin

FROM scratch AS releaser
COPY --from=builder /go/bin/* /
