
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
	rsync -a lib/* $(DST_DIR)/ --exclude='.*'
	haxe $(DEBUG) -js $(DST_DIR)/index.js -lib nodejs -D server -D nodejs -cp $(SRC_DIR) -cp ../../src -main $(MAIN_CLASS) $(CFLAGS)
	haxe $(DEBUG) -js $(DST_DIR)/index.js.client -D client -cp $(SRC_DIR) -cp ../../src -main $(MAIN_CLASS) $(CFLAGS)

.PHONY: clean
clean:
	rm -fr $(DST_DIR)
