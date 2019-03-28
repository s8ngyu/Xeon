ARCHS = arm64 arm64e

DEBUG=0
FINALPACKAGE=0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Xeon
Xeon_FILES = Tweak.xm ./headers/UIImage+ScaledImage.m ./headers/UIImage+animatedGIF.m ./xeonprefs/XENCommon.m ./xeonprefs/XENGIFCommon.m
Xeon_LIBRARIES = imagepicker
Xeon_EXTRA_FRAMEWORKS += Cephei

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += xeonprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
