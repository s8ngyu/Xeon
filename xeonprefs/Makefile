ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:11.4

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = XeonPrefs
XeonPrefs_FILES = XENRootListController.m XENCreditListController.m IconThemes.m XENCommon.m GIFThemes.m XENGIFCommon.m ../headers/UIImage+ScaledImage.m
XeonPrefs_INSTALL_PATH = /Library/PreferenceBundles
XeonPrefs_FRAMEWORKS = UIKit
XeonPrefs_PRIVATE_FRAMEWORKS = Preferences
XeonPrefs_LIBRARIES = imagepicker
XeonPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/XeonPrefs.plist$(ECHO_END)
