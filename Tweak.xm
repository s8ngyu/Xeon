#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <Cephei/HBPreferences.h>
#import <libimagepicker.h>
#import "./headers/UIImage+ScaledImage.h"
#import "./headers/UIImage+animatedGIF.h"
#import "./xeonprefs/XENCommon.h"
#import "./xeonprefs/XENGIFCommon.h"

//Tweak Enabled
static bool isEnabled = true;
static bool debug = false; //Don't enable this.
//Custom Image
static bool isCustomImageEnabled = true;
static bool imageInFrontOfCarrierText = true;
static bool imageInFrontOfTimeText = true;
static int whereToPutImage = 0;
static int imageColor = 1;
static int themesOrImage = 0;
static bool hideCarrierText = false;
static bool hideTimeText = false;
static bool usingiPadStyle = false;
static NSData *userCustomImageData = nil;
static UIImageView *gifImage;
static int staticImageSize = 20;
static int gifImagePadding = 0;
//Custom Text
static bool isCustomTextEnabled = false;
static bool textInFrontOfCarrierText = false;
static bool textInFrontOfTimeText = false;
static int whereToPutText = 0;
static NSString *customText = @"";
//Custom Carrier
static bool isCustomCarrierEnabled = false;
static NSString *customCarrier = nil;
//Custom Cellular Text
static bool isCustomCellularTextEnabled = false;
static NSString *customCellularText = @"";
//Other Settings
static bool adjustFontSize = true;
//Custom Theme
static XENTheme *currentTheme;
static XENGIFTheme *currentGIFTheme;

@interface _UIStatusBarItem : NSObject
@end

@interface _UIStatusBarCellularItem : _UIStatusBarItem
@end

@interface _UIStatusBarStringView : UILabel
@property (nonatomic,copy) NSString * originalText;
@property (nonatomic, assign) BOOL isServiceView;
@property (nonatomic, assign) BOOL isTime;
-(void)setText:(id)arg1;
@end

@interface _UIStatusBarTimeItem : _UIStatusBarItem
@property (nonatomic, retain) _UIStatusBarStringView * shortTimeView;
@property (nonatomic, retain) _UIStatusBarStringView * pillTimeView;
@end

@interface SBStatusBarStateAggregator : NSObject
+(id)sharedInstance;
-(void)_updateServiceItem;
@end

@interface SBTelephonySubscriptionInfo : NSObject
-(NSString *)operatorName;
@end

@interface SBFLockScreenDateView : UIView
-(void)layoutSubviews;
@end

%group Xeon
	%hook _UIStatusBarCellularItem 
	-(_UIStatusBarStringView *)serviceNameView {
		_UIStatusBarStringView *orig = %orig;
		orig.isServiceView = TRUE;
		return orig;
	}
	%end

	%hook _UIStatusBarTimeItem
	-(_UIStatusBarStringView *)shortTimeView{
		_UIStatusBarStringView *orig = %orig;
		orig.isTime = TRUE;
		return orig;
	}
	%end
%end

%group XENCustomImage
	%hook _UIStatusBarStringView
	%property (nonatomic, assign) BOOL isServiceView;
	%property (nonatomic, assign) BOOL isTime;
	-(void)setText:(id)arg1 {
		%orig;

		for (UIView *subview in [self subviews]) {
			[subview removeFromSuperview];
		}

		if (whereToPutImage == 0) {
			imageInFrontOfCarrierText = true;
			imageInFrontOfTimeText = false;
		} else if (whereToPutImage == 1) {
			imageInFrontOfCarrierText = false;
			imageInFrontOfTimeText = true;
		} else if (whereToPutImage == 2) {
			imageInFrontOfCarrierText = true;
			imageInFrontOfTimeText = true;
		}

		if (themesOrImage == 0 || themesOrImage == 1) {
			if (self.isServiceView) {
				if (imageInFrontOfCarrierText) {
					NSString *space = @" ";
					NSString *carrierText = arg1;
					if (arg1 != nil) {
						carrierText = [space stringByAppendingString:arg1];
					} else {
						%orig(space);
					}

					if (hideCarrierText) {
						carrierText = @"";
					}

					UIImage *userCustomImage = [UIImage imageWithData:userCustomImageData];

					UIImage *img = [currentTheme getIcon:@"logo@3x.png"];
					if (!img) {
						img = [currentTheme getIcon:@"logo@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"etched@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"black@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"silber@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"dark@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"light@3x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"light@2x.png"];
					}

					UIImage *newImage = nil;

					if (themesOrImage == 0) {
						if (hideCarrierText) {
							newImage = [img scaleImageToSize:CGSizeMake(40, staticImageSize)];
						} else {
							newImage = [img scaleImageToSize:CGSizeMake(staticImageSize, staticImageSize)];
						}
					} else {
						if (hideCarrierText) {
							newImage = [userCustomImage scaleImageToSize:CGSizeMake(40, staticImageSize)];
						} else {
							newImage = [userCustomImage scaleImageToSize:CGSizeMake(staticImageSize, staticImageSize)];
						}
					}

					if (imageColor == 0) {
						newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
					}

					NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
					imageAttachment.image = newImage;
					CGFloat imageOffsetY = -5.0;
					imageAttachment.bounds = CGRectMake(0, imageOffsetY, imageAttachment.image.size.width, imageAttachment.image.size.height);
					NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
					
					NSMutableAttributedString *imageFixText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
					[imageFixText appendAttributedString:attachmentString];
					[imageFixText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:0] range:NSMakeRange(0, imageFixText.length)];
					[imageFixText appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];

					NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
					[completeText appendAttributedString:imageFixText];
					NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:carrierText];
					[completeText appendAttributedString:textAfterIcon];
					self.textAlignment = NSTextAlignmentRight;
					self.attributedText = completeText;
				} else {
					%orig;
				}
			}

			if (self.isTime) {
				if (imageInFrontOfTimeText) {
					NSString *space = @" ";
					NSString *carrierText = arg1;

					if (arg1 != nil) {
						carrierText = [space stringByAppendingString:arg1];
					} else {
						%orig(space);
					}
					
					if (hideTimeText) {
						carrierText = @"";
					}

					UIImage *userCustomImage = [UIImage imageWithData:userCustomImageData];

					UIImage *img = [currentTheme getIcon:@"logo@3x.png"];
					if (!img) {
						img = [currentTheme getIcon:@"logo@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"etched@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"black@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"silber@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"dark@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"light@3x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"light@2x.png"];
					}

					UIImage *newImage = nil;

					if (themesOrImage == 0) {
						if (hideCarrierText) {
							newImage = [img scaleImageToSize:CGSizeMake(40, staticImageSize)];
						} else {
							newImage = [img scaleImageToSize:CGSizeMake(staticImageSize, staticImageSize)];
						}
					} else {
						if (hideCarrierText) {
							newImage = [userCustomImage scaleImageToSize:CGSizeMake(40, staticImageSize)];
						} else {
							newImage = [userCustomImage scaleImageToSize:CGSizeMake(staticImageSize, staticImageSize)];
						}
					}

					if (imageColor == 0) {
						newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
					}

					NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
					imageAttachment.image = newImage;
					CGFloat imageOffsetY = -5.0;
					imageAttachment.bounds = CGRectMake(0, imageOffsetY, imageAttachment.image.size.width, imageAttachment.image.size.height);
					NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
					
					NSMutableAttributedString *imageFixText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
					[imageFixText appendAttributedString:attachmentString];
					[imageFixText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:0] range:NSMakeRange(0, imageFixText.length)];
					[imageFixText appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];

					NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
					[completeText appendAttributedString:imageFixText];
					NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:carrierText];
					[completeText appendAttributedString:textAfterIcon];
					self.textAlignment = NSTextAlignmentRight;
					self.attributedText = completeText;
					if (adjustFontSize) {
						[self setAdjustsFontSizeToFitWidth:YES];
					}
				} else {
					%orig;
				}
			}

			if (usingiPadStyle && [arg1 containsString:@":"]) {
				if (imageInFrontOfTimeText) {
					NSString *space = @" ";
					NSString *carrierText = arg1;
					
					if (arg1 != nil) {
						carrierText = [space stringByAppendingString:arg1];
					} else {
						%orig(space);
					}
					
					if (hideTimeText) {
						carrierText = @"";
					}

					UIImage *userCustomImage = [UIImage imageWithData:userCustomImageData];

					UIImage *img = [currentTheme getIcon:@"logo@3x.png"];
					if (!img) {
						img = [currentTheme getIcon:@"logo@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"etched@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"black@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"silber@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"dark@2x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"light@3x.png"];
					}
					if (!img) {
						img = [currentTheme getIcon:@"light@2x.png"];
					}

					UIImage *newImage = nil;

					if (themesOrImage == 0) {
						if (hideCarrierText) {
							newImage = [img scaleImageToSize:CGSizeMake(40, staticImageSize)];
						} else {
							newImage = [img scaleImageToSize:CGSizeMake(staticImageSize, staticImageSize)];
						}
					} else {
						if (hideCarrierText) {
							newImage = [userCustomImage scaleImageToSize:CGSizeMake(40, staticImageSize)];
						} else {
							newImage = [userCustomImage scaleImageToSize:CGSizeMake(staticImageSize, staticImageSize)];
						}
					}

					if (imageColor == 0) {
						newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
					}

					NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
					imageAttachment.image = newImage;
					CGFloat imageOffsetY = -5.0;
					imageAttachment.bounds = CGRectMake(0, imageOffsetY, imageAttachment.image.size.width, imageAttachment.image.size.height);
					NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
					
					NSMutableAttributedString *imageFixText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
					[imageFixText appendAttributedString:attachmentString];
					[imageFixText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:0] range:NSMakeRange(0, imageFixText.length)];
					[imageFixText appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];

					NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
					[completeText appendAttributedString:imageFixText];
					NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:carrierText];
					[completeText appendAttributedString:textAfterIcon];
					self.textAlignment = NSTextAlignmentRight;
					self.attributedText = completeText;
					if (adjustFontSize) {
						[self setAdjustsFontSizeToFitWidth:YES];
					}
				} else {
					%orig;
				}
			}
		}

		if (themesOrImage == 2 || themesOrImage == 3) {
			NSString *space = @"        ";
			NSString *carrierText = arg1;

			if (arg1 != nil) {
				carrierText = [space stringByAppendingString:arg1];
			}
			
			if (self.isServiceView && imageInFrontOfCarrierText) {
				if (arg1 == nil) {
					%orig(space);
				}

				if (hideCarrierText) {
					%orig(space);
				} else {
					%orig(carrierText);
				}
				NSData *gifImageData = [currentGIFTheme getGIFData:@"animated.gif"];

				UIImage *animatedimg = [UIImage animatedImageWithAnimatedGIFData:gifImageData];
				UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:userCustomImageData];

				gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, gifImagePadding, staticImageSize, staticImageSize)];
				if (themesOrImage == 2) {
					gifImage.image = animatedimg;
				} else {
					gifImage.image = userCustomImage;
				}

				[self addSubview:gifImage];
			}

			if (self.isTime && imageInFrontOfTimeText) {
				if (arg1 == nil) {
					%orig(space);
				}

				if (hideTimeText) {
					%orig(space);
				} else {
					%orig(carrierText);
				}

				if (adjustFontSize) {
					[self setAdjustsFontSizeToFitWidth:YES];
				}

				NSData *gifImageData = [currentGIFTheme getGIFData:@"animated.gif"];

				UIImage *animatedimg = [UIImage animatedImageWithAnimatedGIFData:gifImageData];
				UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:userCustomImageData];

				gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, gifImagePadding, staticImageSize, staticImageSize)];
				if (themesOrImage == 2) {
					gifImage.image = animatedimg;
				} else {
					gifImage.image = userCustomImage;
				}

				[self addSubview:gifImage];
			}

			if (!self.isTime && usingiPadStyle && [arg1 containsString:@":"]) {
				NSString *sp1 = @"      ";
				NSString *ct1 = arg1;

				if (arg1 != nil) {
					ct1 = [sp1 stringByAppendingString:arg1];
				} else {
					%orig(sp1);
				}

				if (hideTimeText) {
					%orig(sp1);
				} else {
					%orig(ct1);
				}

				NSData *gifImageData = [currentGIFTheme getGIFData:@"animated.gif"];

				UIImage *animatedimg = [UIImage animatedImageWithAnimatedGIFData:gifImageData];
				UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:userCustomImageData];

				gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, gifImagePadding, staticImageSize - 5, staticImageSize - 5)];
				if (themesOrImage == 2) {
					gifImage.image = animatedimg;
				} else {
					gifImage.image = userCustomImage;
				}

				[self addSubview:gifImage];
			}
		}
	}
	%end
%end

%group XENCustomText
	%hook _UIStatusBarStringView
	%property (nonatomic, assign) BOOL isServiceView;
	%property (nonatomic, assign) BOOL isTime;
	-(void)setText:(id)arg1 {
		%orig;

		if (whereToPutText == 0) {
			textInFrontOfCarrierText = true;
			textInFrontOfTimeText = false;
		} else if (whereToPutText == 1) {
			textInFrontOfCarrierText = false;
			textInFrontOfTimeText = true;
		} else if (whereToPutText == 2) {
			textInFrontOfCarrierText = true;
			textInFrontOfTimeText = true;
		}

		if (self.isServiceView) {
			if (textInFrontOfCarrierText) {
				NSString *carrierString = arg1;
				NSString *spyString = customText;
				NSString *statusString = [spyString stringByAppendingString:carrierString];

				%orig(statusString);
			}
		}
		
		if (self.isTime) {
			if (textInFrontOfTimeText) {
				NSString *timeString = arg1;
				NSString *spyString = customText;
				NSString *statusString = [spyString stringByAppendingString:timeString];

				%orig(statusString);
			}
		}

		if (!self.isTime && usingiPadStyle && [arg1 containsString:@":"]) {
			if (textInFrontOfTimeText) {
				NSString *timeString = arg1;
				NSString *spyString = customText;
				NSString *statusString = [spyString stringByAppendingString:timeString];

				%orig(statusString);
			}
		}
	}
	%end
%end

%group XENCustomCarrier
	%hook SBTelephonySubscriptionInfo
	-(NSString *)operatorName {
		if (%orig == nil) {
			return nil;
		} else {
			return customCarrier;
		}
	}
	%end
%end

%group XENCustomCellularText
	%hook _UIStatusBarStringView
	%property (nonatomic, assign) BOOL isServiceView;
	%property (nonatomic, assign) BOOL isTime;
	-(void)setText:(id)arg1 {
		%orig;
		if (!self.isServiceView && !self.isTime && ![arg1 containsString:@":"]) {
			NSArray *cellularArray = [NSArray arrayWithObjects:@"2G", @"3G", @"4G", @"LTE", @"5Gᴱ", nil];
			if ([cellularArray containsObject:arg1]) {
				%orig(customCellularText);
			} else {
				%orig;
			}
		}
	}
	%end
%end

%group debug
%end

void loadPrefs() {
	HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.xeon"];
	//Tweak Enabled
    isEnabled = [([file objectForKey:@"kEnabled"] ?: @(YES)) boolValue];
	//Custom Image
	isCustomImageEnabled = [([file objectForKey:@"kEnableCustomImage"] ?: @(YES)) boolValue];
	whereToPutImage = [([file objectForKey:@"kWhereToPutImage"] ?: @(0)) intValue];
	imageColor = [([file objectForKey:@"kCustomImageColor"] ?: @(1)) intValue];
	themesOrImage = [([file objectForKey:@"kThemesOrImages"] ?: @(0)) intValue];
	hideCarrierText = [([file objectForKey:@"kHideCarrierText"] ?: @(NO)) boolValue];
	hideTimeText = [([file objectForKey:@"kHideTimeText"] ?: @(NO)) boolValue];
	userCustomImageData = [file objectForKey:@"kUserCustomImage"];
	usingiPadStyle = [([file objectForKey:@"kiPadStyle"] ?: @(NO)) boolValue];
	staticImageSize = [([file objectForKey:@"kStaticImageSize"] ?: @(20)) intValue];
	gifImagePadding = [([file objectForKey:@"kGIFPadding"] ?: @(0)) intValue];
	//Custim Text
	isCustomTextEnabled = [([file objectForKey:@"kEnableCustomText"] ?: @(NO)) boolValue];
	whereToPutText = [([file objectForKey:@"kWhereToPutText"] ?: @(0)) intValue];
	customText = [file objectForKey:@"kCustomText"];
	if (!customText) customText = @"";
	//Custom Carrier
	isCustomCarrierEnabled = [([file objectForKey:@"kEnableCustomCarrier"] ?: @(NO)) boolValue];
	customCarrier = [file objectForKey:@"kCustomCarrier"];
	if (!customCarrier) customCarrier = nil;
	//Custom Cellular Text
	isCustomCellularTextEnabled = [([file objectForKey:@"kEnableCustomCellularText"] ?: @(NO)) boolValue];
	customCellularText = [file objectForKey:@"kCustomCellularText"];
	if (!customCellularText) customCellularText = @"";
	//Other Settings
	adjustFontSize = [([file objectForKey:@"kAdjustFontSize"] ?: @(YES)) boolValue];

	//Custom Theme
	NSString *iconTheme = [file objectForKey:@"IconTheme"];
    if(!iconTheme){
        iconTheme = @"Classic Apple";
    }
	currentTheme = [XENTheme themeWithPath:[XENThemesDirectory stringByAppendingPathComponent:iconTheme]];
	//Custom GIF Theme
	NSString *gifTheme = [file objectForKey:@"GIFTheme"];
    if(!gifTheme){
        gifTheme = @"Pac-Man";
    }
	currentGIFTheme = [XENGIFTheme gifThemeWithPath:[XENGIFThemesDirectory stringByAppendingPathComponent:gifTheme]];
}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.peterdev.xeon/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	if (isEnabled) {
		if (debug) %init(debug);
		if (!debug && (isCustomImageEnabled || isCustomTextEnabled)) %init(Xeon);
		if (!debug && isCustomImageEnabled) %init(XENCustomImage);
		if (!(themesOrImage == 2) && !(themesOrImage == 3)) {
			if (!debug && isCustomTextEnabled) %init(XENCustomText);
		}
		if (!debug && isCustomCarrierEnabled) %init(XENCustomCarrier);
		if (!debug && isCustomCellularTextEnabled) %init(XENCustomCellularText);
	}
}