#include <UIKit/UIKit.h>

#define XENPrefsIdentifier @"com.peterdev.xeon"
#define XENNotification @"com.peterdev.xeon/settingschanged"
#define XENThemesDirectory @"/Library/Zeppelin/"

@interface XENTheme : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, retain) UIImage *image;
+ (XENTheme *)themeWithPath:(NSString *)path;
- (NSString *)getPath:(NSString *)filename;
- (UIImage *)getIcon:(NSString *)filename;
- (UIImage *)getImage:(NSString *)filename;
- (id)initWithPath:(NSString *)path;
- (void)preparePreviewImage;

@end