# This Makefile is in the public domain.

HX_THREAD_INFO_VERSION = 0.1.0

CFLAGS = -Wall -O3 -fPIC -fomit-frame-pointer -I ${NEKOPATH}/../vm -D_GNU_SOURCE -I libs/common
MAKESO = $(CC) -shared -Wl,-Bsymbolic
OBJECTS = cffi/neko/hx_thread_info.o

LINUX_64_NDLL_FLAGS = -L${NEKOPATH} -lneko
LINUX_64_NDLLS = ndll/Linux64/hx_thread_info.ndll

ndlls: ${LINUX_64_NDLLS} Makefile
doc: haxedoc.xml Makefile
	mkdir -p doc
	cd doc && haxedoc ../haxedoc.xml
haxelib: hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
try: example.n Makefile
	neko example.n
clean:
	rm -f ${OBJECTS}
	rm -f *.n
purge: clean
	rm -f haxedoc.xml
	rm -Rf doc
	rm -f hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
purge-old: purge
	rm -f hx-thread-info-*.zip
unninstall:
	haxelib remove hx-thread-info
install: hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
	haxelib local hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
install-2.10: hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
	haxelib test hx-thread-info-${HX_THREAD_INFO_VERSION}.zip
dev:
	haxelib dev hx-thread-info ${PWD}/haxelib
all: purge install try
.PHONY: ndlls doc haxelib try run clean purge purge-old unninstall install install-2.10 dev all

${LINUX_64_NDLLS}: ${OBJECTS} Makefile
	mkdir -p ndll/Linux64
	${MAKESO} -o $@ ${OBJECTS} ${LINUX_64_NDLL_FLAGS}
haxedoc.xml: Example.hx neko/vm/Thread.hx Makefile
	haxe doc.hxml
example.n: ndll/Linux64/hx_thread_info.ndll Example.hx neko/vm/Thread.hx Makefile
	mkdir -p bin
	haxe example.hxml
hx-thread-info-${HX_THREAD_INFO_VERSION}.zip: ${LINUX_64_NDLLS} haxedoc.xml Makefile
	zip hx-thread-info-${HX_THREAD_INFO_VERSION}.zip `find . -type f ! -ipath "*/.*" ! -ipath "*/*.zip" ! -ipath "./doc*"`
