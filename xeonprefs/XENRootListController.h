#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>
#import "XENCommon.h"
#import "IconThemes.h"
#import "XENCreditListController.h"
#import <libimagepicker.h>
#import <LIPImageChooseCell.h>

@interface XENRootListController : HBRootListController
- (void)respring:(id)sender;
- (void)setThemeName:(NSString *)name;
@end
