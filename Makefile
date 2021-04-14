export BR2_EXTERNAL := $(shell pwd)

.PHONY: def_all update-ng300-configs

def_all: all

update-ng300-configs: update-defconfig linux-update-defconfig
	@cp $(BR2_EXTERNAL)/output/build/busybox*/.config $(BR2_EXTERNAL)/board/kerio_ng300/busybox.config

%:
	@+$(MAKE) --no-print-directory -C buildroot O=$(BR2_EXTERNAL)/output MAKEFLAGS= $*
