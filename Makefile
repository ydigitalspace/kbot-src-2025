.PHONY: all build image unit-test clean

build: build
all:  image push
test: unit-test

PROJECT=denvasyliev
APP=kbot
BUILDER=docker
TARGETOS=linux
TARGETARCH=arm64
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse HEAD|cut -c1-7)
APP_BUILD_INFO=${VERSION}-$(shell dpkg --print-architecture)

build:
	@echo "Let's build it"
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=$(shell dpkg --print-architecture) go build -o kbot -a -installsuffix cgo -ldflags "-X="github.com/den-vasyliev/kbot/cmd.appVersion=${APP_BUILD_INFO} -v

image:
	@echo "Let's build image"
	${BUILDER} build . -t ${PROJECT}/${APP}:${VERSION}-${TARGETARCH} --no-cache --build-arg APP_BUILD_INFO=${VERSION} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	@echo "Let's push image"
	${BUILDER} push ${PROJECT}/${APP}:${VERSION}-${TARGETARCH}

unit-test:
	@echo "Run tests here..."
	@${BUILDER} build --target unit-test .

lint:
	@echo "Run lint here..."
	@${BUILDER} build --target lint .

clean:
	@echo "Cleaning up..."
	rm -rf kbot