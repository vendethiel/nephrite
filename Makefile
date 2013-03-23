install:
	@echo Building .js files ...
	@coco -cb .
	@lsc -cb .

clean:
	@rm -rf *.js

.PHONY: clean