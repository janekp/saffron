
DST_DIR=build

all: saffron.zip

saffron.zip:
	mkdir -p $(DST_DIR)
	zip $(DST_DIR)/saffron.zip LICENSE
	cd src; zip -i \*.hx -i \*.json -r ../$(DST_DIR)/saffron.zip *

.PHONY: clean
clean:
	rm -fr $(DST_DIR)
