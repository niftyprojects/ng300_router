# Modified from buildroot/package/skeleton-init-common/skeleton-init-common.mk
# and as such is under the licensing terms of Buildroot.

# The skeleton can't depend on the toolchain, since all packages depends on the
# skeleton and the toolchain is a target package, as is skeleton.
# Hence, skeleton would depends on the toolchain and the toolchain would depend
# on skeleton.
SKELETON_RO_ROOT_ADD_TOOLCHAIN_DEPENDENCY = NO
SKELETON_RO_ROOT_ADD_SKELETON_DEPENDENCY = NO
SKELETON_RO_ROOT_PROVIDES = skeleton

SKELETON_RO_ROOT_INSTALL_STAGING = YES
SKELETON_RO_ROOT_PATH = $(SKELETON_RO_ROOT_PKGDIR)/skeleton

define SKELETON_RO_ROOT_INSTALL_TARGET_CMDS
	$(call SYSTEM_RSYNC,$(SKELETON_RO_ROOT_PATH),$(TARGET_DIR))
	$(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(TARGET_DIR))
	$(call SYSTEM_LIB_SYMLINK,$(TARGET_DIR))
	$(INSTALL) -m 0644 support/misc/target-dir-warning.txt \
		$(TARGET_DIR_WARNING_FILE)
endef

# Staging is the toolchain sysroot and needs a valid skeleton in it. It'd be
# possible to have a slimmer version but it's not worth the hassle of making
# another tree.
define SKELETON_RO_ROOT_INSTALL_STAGING_CMDS
	$(call SYSTEM_RSYNC,$(SKELETON_RO_ROOT_PATH),$(STAGING_DIR))
	$(call SYSTEM_USR_SYMLINKS_OR_DIRS,$(STAGING_DIR))
	$(call SYSTEM_LIB_SYMLINK,$(STAGING_DIR))
	$(INSTALL) -d -m 0755 $(STAGING_DIR)/usr/include
endef

SKELETON_RO_ROOT_HOSTNAME = $(call qstrip,$(BR2_TARGET_GENERIC_HOSTNAME))
SKELETON_RO_ROOT_ISSUE = $(call qstrip,$(BR2_TARGET_GENERIC_ISSUE))
SKELETON_RO_ROOT_VAR_DEV = $(call qstrip,$(BR2_PACKAGE_SKELETON_RO_ROOT_VAR_DEVICE))

define SKELETON_RO_ROOT_SET_PATH
        $(SED) 's,@PATH@,$(BR2_SYSTEM_DEFAULT_PATH),' $(TARGET_DIR)/etc/profile
endef
SKELETON_RO_ROOT_TARGET_FINALIZE_HOOKS += SKELETON_RO_ROOT_SET_PATH

define SKELETON_RO_ROOT_SET_VAR_DEVICE
	$(SED) 's,@VAR_DEV@,$(SKELETON_RO_ROOT_VAR_DEV),' $(TARGET_DIR)/etc/fstab
endef
SKELETON_RO_ROOT_TARGET_FINALIZE_HOOKS += SKELETON_RO_ROOT_SET_VAR_DEVICE

ifneq ($(SKELETON_RO_ROOT_HOSTNAME),)
SKELETON_RO_ROOT_HOSTS_LINE = $(SKELETON_RO_ROOT_HOSTNAME)
SKELETON_RO_ROOT_SHORT_HOSTNAME = $(firstword $(subst ., ,$(SKELETON_RO_ROOT_HOSTNAME)))
ifneq ($(SKELETON_RO_ROOT_HOSTNAME),$(SKELETON_RO_ROOT_SHORT_HOSTNAME))
SKELETON_RO_ROOT_HOSTS_LINE += $(SKELETON_RO_ROOT_SHORT_HOSTNAME)
endif
define SKELETON_RO_ROOT_SET_HOSTNAME
	echo "$(SKELETON_RO_ROOT_HOSTNAME)" > $(TARGET_DIR)/var/etc/hostname
	for addr in $(BR2_TARGET_GENERIC_ADDRS); \
	do \
		echo -e "$$addr\t$(SKELETON_RO_ROOT_HOSTS_LINE)"; \
	done >> $(TARGET_DIR)/var/etc/hosts
endef
SKELETON_RO_ROOT_TARGET_FINALIZE_HOOKS += SKELETON_RO_ROOT_SET_HOSTNAME
endif

ifneq ($(SKELETON_RO_ROOT_ISSUE),)
define SKELETON_RO_ROOT_SET_ISSUE
	echo "$(SKELETON_RO_ROOT_ISSUE)" > $(TARGET_DIR)/etc/issue
endef
SKELETON_RO_ROOT_TARGET_FINALIZE_HOOKS += SKELETON_RO_ROOT_SET_ISSUE
endif

ifneq ($(BR2_TARGET_GENERIC_SERIAL_CONSOLE_LOGIN),)
define SKELETON_RO_ROOT_SERIAL_LOGIN
	$(SED) 's|^#\(ttyS0::respawn:/sbin/getty.*\)|\1|' $(TARGET_DIR)/etc/inittab
endef
SKELETON_RO_ROOT_TARGET_FINALIZE_HOOKS += SKELETON_RO_ROOT_SERIAL_LOGIN
endif

$(eval $(generic-package))
