
SRC_DIR=src
DST_DIR=build
MAIN_CLASS=Application
CFLAGS=-dce full
DEBUG=

all: DEBUG = -debug
all: run

release: run

run:
	mkdir -p $(DST_DIR)
	haxe $(DEBUG) -lib nodejs -js $(DST_DIR)/index.js -D nodejs -D server -cp $(SRC_DIR) -cp ../../src -main $(MAIN_CLASS) $(CFLAGS)

.PHONY: clean
clean:
	rm -fr $(DST_DIR)
