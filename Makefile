.DEFAULT_GOAL := debug

TARGET := save-organizer

DEBUG   = .build/debug/$(TARGET)
RELEASE = .build/release/$(TARGET)

DEBUG_FLAGS   :=
RELEASE_FLAGS := -c release

STATIC_DEBUG   := .build/x86_64-swift-linux-musl/debug/$(TARGET)
STATIC_RELEASE := .build/x86_64-swift-linux-musl/release/$(TARGET)

STATIC_FLAGS := --swift-sdk x86_64-swift-linux-musl
STATIC_DEBUG_FLAGS   := $(STATIC_FLAGS)
STATIC_RELEASE_FLAGS := $(STATIC_FLAGS) $(RELEASE_FLAGS)


$(DEBUG):
	swift build $(DEBUG_FLAGS)

$(RELEASE):
	swift build $(RELEASE_FLAGS)

debug:   $(DEBUG)
release: $(RELEASE)

$(STATIC_DEBUG):
	swift build $(STATIC_DEBUG_FLAGS)

$(STATIC_RELEASE):
	swift build $(STATIC_RELEASE_FLAGS)

static-debug: $(STATIC_DEBUG)
static-release: $(STATIC_RELEASE)

all: debug release static-debug static-release

ZIPFILE := builds.zip
$(ZIPFILE): $(DEBUG) $(RELEASE) $(STATIC_DEBUG) $(STATIC_RELEASE)
	mkdir -p builds/debug builds/release builds/static-debug builds/static-release
	@cp $(DEBUG) builds/debug/
	@cp $(RELEASE) builds/release/
	@cp $(STATIC_DEBUG) builds/static-debug/
	@cp $(STATIC_RELEASE) builds/static-release/
	strip builds/**/$(TARGET)
	zip -r $(ZIPFILE) builds/
	rm -r builds/

zip: $(ZIPFILE)

clean:
	$(foreach fi,$(DEBUG) $(RELEASE) $(STATIC_DEBUG) $(STATIC_RELEASE) $(ZIPFILE),rm -f $(fi);)

.PHONY := clean
