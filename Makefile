VERSION=1.4.0
URL=https://github.com/webmproject/libwebp/archive/refs/tags/v$(VERSION).zip

WEBP = WebP.xcframework
WEBPMUX = WebPMux.xcframework
WEBPDEMUX = WebPDemux.xcframework

all:
	$(MAKE) fetch && \
	$(MAKE) build && \
	$(MAKE) clean

build:
	$(MAKE) install_build_tools && \
	cd Build/libwebp-$(VERSION) && \
	sh xcframeworkbuild.sh && \
	rm -rf ../../Sources/$(WEBP) && \
	rm -rf ../../Sources/$(WEBPDEMUX) && \
	mv $(WEBP) ../../Sources/ && \
	mv $(WEBPDEMUX) ../../Sources/

fetch:
	$(MAKE) clean && \
	mkdir -p .temp && \
	curl -L -o .temp/libwebp.zip $(URL) && \
	unzip .temp/libwebp.zip -d Build && \
	$(MAKE) clean_tmp

clean:
	$(MAKE) clean_tmp && \
	$(MAKE) clean_build && \
	$(MAKE) clean_useless_arch

clean_tmp:
	@rm -rf .temp

clean_build:
	@rm -rf Build/**

clean_useless_arch:
	@rm -rf Sources/WebP.xcframework/ios-arm64_x86_64-maccatalyst && \
	rm -rf Sources/WebP.xcframework/macos-arm64_x86_64 && \
	rm -rf Sources/WebPDemux.xcframework/ios-arm64_x86_64-maccatalyst && \
	rm -rf Sources/WebPDemux.xcframework/macos-arm64_x86_64

install_build_tools:
	@if ! command -v autogen &> /dev/null; then \
		echo "autogen not found. Installing via Homebrew..."; \
		brew install autogen; \
	fi
	@if ! command -v automake &> /dev/null; then \
		echo "automake not found. Installing via Homebrew..."; \
		brew install automake; \
	fi

.PHONY: all build fetch clean clean_tmp clean_build install_build_tools