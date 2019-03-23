#import "./headers/UIImage+ScaledImage.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <Cephei/HBPreferences.h>
#import "./xeonprefs/XENCommon.h"
#import <libimagepicker.h>
#import <LIPImageChooseCell.h>
#import "./headers/UIImage+animatedGIF.h"

//Tweak Enabled
static bool isEnabled = true;
static bool debug = true; //Don't enable this.
//Custom Image
static bool isCustomImageEnabled = true;
static bool imageInFrontOfCarrierText = true;
static bool imageInFrontOfTimeText = true;
static int whereToPutImage = 0;
static int imageColor = 1;
static int themesOrImage = 0;
static bool hideCarrierText = false;
static bool hideTimeText = false;
//Custom Text
static bool isCustomTextEnabled = false;
static bool textInFrontOfCarrierText = false;
static bool textInFrontOfTimeText = false;
static int whereToPutText = 0;
static NSString *customText = @"";
//Custom Carrier
static bool isCustomCarrierEnabled = false;
static NSString *customCarrier = @"";
//Other Settings
static bool adjustFontSize = true;
//Custom Theme
static XENTheme *currentTheme;

UIImageView *gifImage;

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
@property (nonatomic,retain) _UIStatusBarStringView * shortTimeView;
@property (nonatomic,retain) _UIStatusBarStringView * pillTimeView;
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

		if (self.isServiceView) {
			if (imageInFrontOfCarrierText) {
				NSString *space = @" ";
				NSString *carrierText = [space stringByAppendingString:arg1];
				if (hideCarrierText) {
					carrierText = @"";
				}

				NSString *const imagesDomain = @"com.peterdev.xeon";
				NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserCustomImage" inDomain:imagesDomain];
				UIImage *userCustomImage = [UIImage imageWithData:data];
				//UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:data];

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
						newImage = [img scaleImageToSize:CGSizeMake(40, 20)];
					} else {
						newImage = [img scaleImageToSize:CGSizeMake(20, 20)];
					}
				} else {
					if (hideCarrierText) {
						newImage = [userCustomImage scaleImageToSize:CGSizeMake(40, 20)];
					} else {
						newImage = [userCustomImage scaleImageToSize:CGSizeMake(20, 20)];
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
			}
		}

		if (imageInFrontOfTimeText) {
			if ([arg1 containsString:@":"]) {
				NSString *space = @" ";
				NSString *carrierText = [space stringByAppendingString:arg1];
				if (hideTimeText) {
					carrierText = @"";
				}

				NSString *const imagesDomain = @"com.peterdev.xeon";
				NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserCustomImage" inDomain:imagesDomain];
				UIImage *userCustomImage = [UIImage imageWithData:data];
				//UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:data];

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
					if (hideTimeText) {
						newImage = [img scaleImageToSize:CGSizeMake(40, 20)];
					} else {
						newImage = [img scaleImageToSize:CGSizeMake(20, 20)];
					}
				} else {
					if (hideTimeText) {
						newImage = [userCustomImage scaleImageToSize:CGSizeMake(40, 20)];
					} else {
						newImage = [userCustomImage scaleImageToSize:CGSizeMake(20, 20)];
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
		
		if (textInFrontOfTimeText) {
			if ([arg1 containsString:@":"]) {
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
	return customCarrier;
	}
	%end
%end

%group debug
	%hook _UIStatusBarStringView
	%property (nonatomic, assign) BOOL isServiceView;
	%property (nonatomic, assign) BOOL isTime;
	-(void)setText:(id)arg1 {
		%orig;
		if (self.isServiceView) {
			NSString *space = @"        ";
			NSString *carrierText = [space stringByAppendingString:arg1];
			%orig(carrierText);
			NSString *const imagesDomain = @"com.peterdev.xeon";
			NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserCustomImage" inDomain:imagesDomain];
			UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:data];

			[gifImage removeFromSuperview];
			gifImage.image = nil;
			gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,-5,25,25)];
			gifImage.image = userCustomImage;
			[self addSubview:gifImage];
		}

		if (self.isTime) {
			NSString *space = @"        ";
			NSString *carrierText = [space stringByAppendingString:arg1];
			%orig(carrierText);
			NSString *const imagesDomain = @"com.peterdev.xeon";
			NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserCustomImage" inDomain:imagesDomain];
			UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:data];
			
			[gifImage removeFromSuperview];
			gifImage.image = nil;
			gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,-5,25,25)];
			gifImage.image = userCustomImage;
			[self addSubview:gifImage];
		}

		if (!self.isTime && [arg1 containsString:@":"]) {
			NSString *space = @"        ";
			NSString *carrierText = [space stringByAppendingString:arg1];
			%orig(carrierText);
			NSString *const imagesDomain = @"com.peterdev.xeon";
			NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserCustomImage" inDomain:imagesDomain];
			UIImage *userCustomImage = [UIImage animatedImageWithAnimatedGIFData:data];
			
			[gifImage removeFromSuperview];
			gifImage.image = nil;
			gifImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,-5,20,20)];
			gifImage.image = userCustomImage;
			[self addSubview:gifImage];
		}
	}
	%end

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
	//Custim Text
	isCustomTextEnabled = [([file objectForKey:@"kEnableCustomText"] ?: @(NO)) boolValue];
	whereToPutText = [([file objectForKey:@"kWhereToPutText"] ?: @(0)) intValue];
	customText = [file objectForKey:@"kCustomText"];
	if (!customText) customText = @"";
	//Custom Carrier
	isCustomCarrierEnabled = [([file objectForKey:@"kEnableCustomCarrier"] ?: @(NO)) boolValue];
	customCarrier = [file objectForKey:@"kCustomCarrier"];
	if (!customCarrier) customCarrier = @"";
	//Other Settings
	adjustFontSize = [([file objectForKey:@"kAdjustFontSize"] ?: @(YES)) boolValue];

	//Custom Theme
	NSString *iconTheme = [file objectForKey:@"IconTheme"];
    if(!iconTheme){
        iconTheme = @"Classic Apple";
    }

	currentTheme = [XENTheme themeWithPath:[XENThemesDirectory stringByAppendingPathComponent:iconTheme]];
}

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, (CFStringRef)XENNotification, NULL, kNilOptions);

	if (isEnabled) {
		if (debug) %init(debug);
		if (!debug && (isCustomImageEnabled || isCustomTextEnabled)) %init(Xeon);
		if (!debug & isCustomImageEnabled) %init(XENCustomImage);
		if (!debug & isCustomTextEnabled) %init(XENCustomText);
		if (!debug & isCustomCarrierEnabled) %init(XENCustomCarrier);
	}
}