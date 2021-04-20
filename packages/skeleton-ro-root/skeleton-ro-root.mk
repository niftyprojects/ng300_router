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

$(eval $(generic-package))
