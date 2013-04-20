TS=coco

install: index.js

index.js:
	@echo Building .js file ...
	@$(TS) -cb index

.PHONY: clean test

clean:
	@echo Cleaning ...
	@rm index.js

test: clean index.js
	@$(TS) test/run