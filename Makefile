.SILENT:

PROJECT_NAME='auto-sh1mmer-arch'
BOARD_TO_TEST='dedede'

test:
	mkdir -p ./build
	./shim.sh $(BOARD_TO_TEST)