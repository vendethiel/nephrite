TS=coco

install: index.js
	@echo Building .js file ...

index.js:
	@$(TS) -cb index

.PHONY: clean test

clean:
	@rm -rf *.js

test: clean index.js
	@$(TS) test/run