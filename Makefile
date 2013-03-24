install: index.co
	@echo Building .js file ...
	@coco -cb .

clean:
	@rm -rf *.js

.PHONY: clean