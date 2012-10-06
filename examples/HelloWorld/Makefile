
SRC_DIR=src
DST_DIR=build
MAIN_CLASS=Application
CFLAGS=--dead-code-elimination
DEBUG=

all: server

debug: DEBUG = -debug
debug: server

server:
	mkdir -p $(DST_DIR)
	rsync -a lib/private/* $(DST_DIR)/ --exclude='.*'
	haxe $(DEBUG) -js $(DST_DIR)/index.js -lib nodejs -D server -D nodejs -cp $(SRC_DIR) -cp ../../src -main $(MAIN_CLASS) $(CFLAGS)

.PHONY: clean
clean:
	rm -fr $(DST_DIR)
