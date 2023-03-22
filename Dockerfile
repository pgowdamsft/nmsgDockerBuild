# Multistage Dockerfile to build libwdns -> nmsg -> go-nmsg
# Author: Pradeep Gowda
# Date: 2023-03-21
FROM mcr.microsoft.com/mirror/docker/library/ubuntu:18.04 as build

WORKDIR /app
RUN apt update
RUN apt upgrade -y
RUN apt install -y automake libtool pkg-config \
	zlib1g zlib1g-dev git

# Build libwdns
FROM build as stage1
WORKDIR /app
RUN apt install -y libpcap0.8-dev libzmq3-dev libyajl-dev yajl-tools python3
RUN git clone https://github.com/farsightsec/wdns.git
RUN cd wdns; ./autogen.sh && \
	./configure && \
	make && make install

# Build nmsg
FROM stage1 as stage2
WORKDIR /app
RUN apt install -y libprotobuf-c-dev protobuf-c-compiler
RUN git clone https://github.com/farsightsec/nmsg.git
RUN cd nmsg; \
	./autogen.sh && \
	./configure && \
	make && make install

# Build go-nmsg
# ; go mod download && go mod tidy && go mod download
# https://stackoverflow.com/a/59788520
FROM stage2 as stage3
WORKDIR /app
RUN apt install -y gccgo-go
RUN git clone https://github.com/farsightsec/go-nmsg.git
RUN cd go-nmsg/cgo-nmsg; \
	go build
