.PHONY: build test bundle clean

build:
	swift build -c release

test:
	swift test

bundle: build
	bash scripts/bundle.sh

clean:
	swift package clean
	rm -rf Go2Shell.app
