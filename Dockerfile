# syntax=docker/dockerfile:experimental
FROM golang:1.19 as builder
WORKDIR /go/src/app
COPY . .
RUN export GOPATH=/go
RUN go get -d -v .

FROM builder AS build
ARG APP_BUILD_INFO
ARG TARGETOS
ARG TARGETARCH
RUN gofmt -s -w ./
RUN APP_BUILD_INFO=$(git describe --tags --abbrev=0)-$(git rev-parse --short HEAD)-${TARGETARCH} && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH}  \
    go build -o kbot -a -installsuffix cgo \ 
    -ldflags "-X="github.com/den-vasyliev/kbot/cmd.appVersion=${APP_BUILD_INFO} -v 

FROM golangci/golangci-lint:v1.27-alpine AS lint-base

FROM builder AS unit-test
RUN go test -v 

FROM builder AS lint
COPY --from=lint-base /usr/bin/golangci-lint /usr/bin/golangci-lint
RUN ls -l 
RUN GO111MODULE=on golangci-lint run --disable-all -E typecheck main.go

FROM scratch AS bin
WORKDIR /
COPY --from=build /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/kbot"]