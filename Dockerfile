# build nsmg
# docker pull mcr.microsoft.com/mirror/docker/library/ubuntu:18.04
FROM mcr.microsoft.com/mirror/docker/library/ubuntu:18.04 as build

WORKDIR /app
RUN apt update
RUN apt upgrade -y
RUN apt install -y automake libtool pkg-config \
	libzmq3-dev libpcap0.8-dev libprotobuf-c-dev protobuf-c-compiler \
	libyajl-dev yajl-tools zlib1g zlib1g-dev git gccgo-go python3

# Build libwdns
FROM build as stage1
WORKDIR /app
RUN git clone https://github.com/farsightsec/wdns.git
RUN cd wdns; ./autogen.sh && ./configure && make && make install

# Build nmsg
FROM stage1 as stage2
WORKDIR /app
RUN git clone https://github.com/farsightsec/nmsg.git
RUN cd nmsg; ./autogen.sh && ./configure && make && make install

# Build go-nmsg
# ; go mod download && go mod tidy && go mod download
# https://stackoverflow.com/a/59788520
FROM stage2 as stage3
WORKDIR /app
RUN git clone https://github.com/farsightsec/go-nmsg.git
RUN cd go-nmsg/cgo-nmsg; go build
RUN echo $(ls -1 /app/go-nmsg/cgo-nmsg)
