.PHONY: all build unit-test clean

all: build 
test: unit-test

BUILDER=docker
PLATFORM=linux
TARGETARCH=arm64
VERSION=$(git describe --tags --abbrev=0)-$(git rev-parse HEAD|cut -c1-7)

build:
	@echo "Let's build it"
	${BUILDER} build . --no-cache --build-arg APP_BUILD_INFO=${VERSION}

unit-test:
	@echo "Run tests here..."
	@${BUILDER} build --target unit-test .

lint:
	@echo "Run lint here..."
	@${BUILDER} build --target lint .

clean:
	@echo "Cleaning up..."
	rm -rf bin