MOD_NAME := $(shell head -n 1 mod/readme.md | cut -c 3-)
MOD_CREATOR := DanTheMan827
MOD_CATEGORY := SD
GIT_COMMIT := $(shell echo "`git rev-parse --short HEAD``git diff-index --quiet HEAD -- || echo '-dirty'`")
GIT_TAG := $(shell git describe --tags)
MOD_FILENAME := $(shell basename "`git config --get remote.origin.url`" .hmod.git)

all: out/$(MOD_FILENAME)-$(GIT_COMMIT).hmod

out/$(MOD_FILENAME)-$(GIT_COMMIT).hmod: mod/sfdisk
	mkdir -p out/ temp/
	mkdir -p out/ temp/
	rsync -a mod/ temp/ --links --delete
	
	printf "%s\n" \
	  "---" \
	  "Name: $(MOD_NAME)" \
	  "Creator: $(MOD_CREATOR)" \
	  "Category: $(MOD_CATEGORY)" \
	  "Version: $(GIT_TAG)" \
	  "Packed on: $(shell date)" \
	  "Git commit: $(GIT_COMMIT)" \
	  "---" > temp/readme.md
	
	sed 1d mod/readme.md >> temp/readme.md
	cd temp/; tar --owner=0 --group=0 -czvf "../$@" *
	rm -r temp/
	touch "$@"

mod/sfdisk: util-linux-2.31.1/sfdisk.static
	cp "$<" "$@"
	chmod +x "$@"

util-linux-2.31.1/sfdisk.static: util-linux-2.31.1/configure
	cd "util-linux-2.31.1/" && \
	./configure --host=arm-linux-gnueabihf --enable-static-programs=sfdisk --without-tinfo --without-util --without-ncurses && \
	make sfdisk.static && \
	arm-linux-gnueabihf-strip sfdisk.static

util-linux-2.31.1/configure: util-linux-2.31.1.tar.xz
	tar -xJvf "$<"
	touch "$@"

util-linux-2.31.1.tar.xz:
	wget "https://www.kernel.org/pub/linux/utils/util-linux/v2.31/util-linux-2.31.1.tar.xz" -O "$@" --no-use-server-timestamps


clean: clean-hmod
	-rm -rf "util-linux-2.31.1.tar.xz" "util-linux-2.31.1/"

clean-hmod:
	-rm -rf "out/" "mod/sfdisk"

.PHONY: clean clean-hmod
