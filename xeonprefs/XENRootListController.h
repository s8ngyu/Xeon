#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>
#import "XENCreditListController.h"
#import "XENLeftListController.h"
#import "XENRightListController.h"


@interface XENRootListController : HBRootListController
- (void)respring:(id)sender;
- (void)resetPrefs:(id)sender;
@end
