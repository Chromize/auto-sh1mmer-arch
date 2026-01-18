.SILENT:

PROJECT_NAME='auto-sh1mmer-arch'
BOARD_TO_TEST='dedede'

#
#  This script will not work on your machine...
#
#  This script was written so I can continuously test these scripts.
#
#  Also, this script sucks. Don't mind this..
#
test:
	sudo rm -rf ~/chromiumos
	rm -rf ~/Playground/$(PROJECT_NAME)
	cp -r ~/Projects/$(PROJECT_NAME) ~/Playground
	mkdir -p ~/Playground/$(PROJECT_NAME)/build
	./shim.sh $(BOARD_TO_TEST)