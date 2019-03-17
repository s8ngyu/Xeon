ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Xeon
Xeon_FILES = Tweak.xm ./headers/UIImage+ScaledImage.m ./xeonprefs/XENCommon.m
Xeon_EXTRA_FRAMEWORKS += Cephei

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += xeonprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
