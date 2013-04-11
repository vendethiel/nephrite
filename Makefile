install: index.co
	@echo Building .js file ...
	@coco -cb .

clean:
	@rm -rf *.js

test:
	@coco test/run 

.PHONY: clean test