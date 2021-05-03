SHOREWALL6_VERSION_MAJOR = 5.2
SHOREWALL6_VERSION = $(SHOREWALL6_VERSION_MAJOR).8
SHOREWALL6_SITE = https://shorewall.org/pub/shorewall/$(SHOREWALL6_VERSION_MAJOR)/shorewall-$(SHOREWALL6_VERSION)
SHOREWALL6_SOURCE = shorewall6-$(SHOREWALL6_VERSION).tar.bz2

SHOREWALL6_LICENSE = GPLv2 or later
SHOREWALL6_LICENSE_FILES = LICENSE

define SHOREWALL6_CONFIGURE
	$(@D)/configure --vendor=default --initfile=S41shorewall6 --confdir=/var/etc
endef
SHOREWALL6_CONFIGURE_CMDS += $(SHOREWALL6_CONFIGURE)

define SHOREWALL6_INSTALL
	DESTDIR=$(TARGET_DIR) $(@D)/install.sh 
endef
SHOREWALL6_INSTALL_TARGET_CMDS += $(SHOREWALL6_INSTALL)

$(eval $(generic-package))