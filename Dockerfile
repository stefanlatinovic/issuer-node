FROM ubuntu:22.04 as builder

ARG VERSION

COPY . /service

WORKDIR /service

RUN apt-get update
RUN apt-get install -y wget build-essential ca-certificates
RUN wget https://go.dev/dl/go1.19.linux-arm64.tar.gz

# Configure Go
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH /usr/local/go/bin:/go/bin:$PATH
ENV GOBIN /service/bin

RUN tar -xvf go1.19.linux-arm64.tar.gz
RUN mv go /usr/local

RUN go mod download
RUN go install -buildvcs=false -ldflags "-X main.build=${VERSION}" ./cmd/...
RUN mv /service/bin/* /service/
###Build an issuer image
#FROM ubuntu:22.04
#
#WORKDIR /service
#
#RUN apt-get update
#RUN apt-get install -y build-essential libomp-dev ca-certificates
#
#COPY --from=builder /service/bin/migrate /service
#COPY --from=builder /service/bin/platform /service
#COPY --from=builder /service/bin/pending_publisher /service
#COPY --from=builder /service/config.toml /service/config.toml
#COPY --from=builder /service/api/spec.html /service/api/spec.html
#COPY --from=builder /service/api/api.yaml /service/api/api.yaml
#COPY --from=builder "/go/pkg/mod/github.com/wasmerio/wasmer-go@v1.0.4/wasmer/packaged/lib/" \
#"/go/pkg/mod/github.com/wasmerio/wasmer-go@v1.0.4/wasmer/packaged/lib/"
#COPY --from=builder "/service/pkg/credentials" \
#"/service/pkg/credentials"
