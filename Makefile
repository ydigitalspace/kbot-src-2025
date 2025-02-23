.PHONY: all

all:  image push

APP=$(shell basename $(shell git remote get-url origin))
REGESTRY=denvasyliev
CURRENTARCH=$(shell dpkg --print-architecture)
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse HEAD|cut -c1-7)
HELM_VERSION=$(shell git describe --tags --abbrev=0)

TARGETOS=linux
TARGETARCH=arm64

format:
	gofmt -s -w ./

lint: format
	golint

test: lint
	go test -v

build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=$(shell dpkg --print-architecture) go build -v -o kbot -ldflags "-X="github.com/den-vasyliev/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH} --no-cache --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}

helm-package:
	helm package helm/ --version ${HELM_VERSION} --app-version ${VERSION}

helm-push:
	helm push ${APP}-${HELM_VERSION}.tgz oci://ghcr.io/${REGESTRY}/charts

clean:
	rm -rf kbot
	rm -f ${APP}-*.tgz