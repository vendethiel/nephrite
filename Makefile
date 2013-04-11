install: index.co
	@echo Building .js file ...
	@coco -cb .

clean:
	@rm -rf *.js

test: index.co
	@coco test/run 

.PHONY: clean test