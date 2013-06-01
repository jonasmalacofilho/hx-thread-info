# This Makefile is in the public domain.

HX_THREAD_INFO_VERSION = 0.1.0

CFLAGS = -Wall -O3 -fPIC -fomit-frame-pointer -I ${NEKOPATH}/../vm -D_GNU_SOURCE -I libs/common
MAKESO = $(CC) -shared -Wl,-Bsymbolic
OBJECTS = src/cffi/hx_thread_info.o

LINUX_64_NDLL_FLAGS = -L${NEKOPATH} -lneko
LINUX_64_NDLLS = haxelib/ndll/Linux64/hx_thread_info.ndll

ndlls: ${LINUX_64_NDLLS} Makefile
doc: haxelib/haxedoc.xml Makefile
	mkdir -p doc
	cd doc && haxedoc ../haxelib/haxedoc.xml
haxelib: hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
test: bin/test.n Makefile
	neko bin/test.n
clean:
	rm ${OBJECTS}
	rm -Rf doc
	rm -Rf bin/*.n
	rm -Rf hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
clean-all: clean
	rm -f hx-thread-info-*.zip
unninstall:
	haxelib remove hx-thread-info
install: haxelib
	haxelib local hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
install-2.10: haxelib
	haxelib test hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
dev:
	haxelib dev hx-thread-info ${PWD}/haxelib
all: clean haxelib install test
.PHONY: ndlls doc haxelib test clean clean-all unninstall install install-2.10 dev all

${LINUX_64_NDLLS}: ${OBJECTS} Makefile
	mkdir -p haxelib/ndll/Linux64
	${MAKESO} -o $@ ${OBJECTS} ${LINUX_64_NDLL_FLAGS}
haxelib/haxedoc.xml: src/test/Test.hx haxelib/neko/vm/Thread.hx Makefile
	haxe doc.hxml
hx-thread-info-${HX_THREAD_INFO_VERSION}.zip: ndlls doc
	cd haxelib && zip -r ../hx-thread-info-${HX_THREAD_INFO_VERSION}.zip .
bin/test.n: haxelib/ndll/Linux64/hx_thread_info.ndll src/test/Test.hx haxelib/neko/vm/Thread.hx Makefile
	mkdir -p bin
	haxe test.hxml
