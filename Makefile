export BR2_EXTERNAL := $(shell pwd)

.PHONY: def_all

def_all: all

%:
	@+$(MAKE) --no-print-directory -C buildroot O=$(BR2_EXTERNAL)/output MAKEFLAGS= $*
