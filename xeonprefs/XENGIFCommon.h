#define XENPrefsIdentifier @"com.peterdev.xeon"
#define XENNotification @"com.peterdev.xeon/settingschanged"
#define XENGIFThemesDirectory @"/Library/Xeon/GIF/"

@interface XENGIFTheme : NSObject

@property (nonatomic, copy) NSString *gifName;
@property (nonatomic, copy) NSString *gifPath;
@property (nonatomic, retain) UIImage *gifImage;
+ (XENGIFTheme *)gifThemeWithPath:(NSString *)path;
- (NSString *)getGIFPath:(NSString *)filename;
- (UIImage *)getGIFIcon:(NSString *)filename;
- (UIImage *)getGIFImage:(NSString *)filename;
- (NSData *)getGIFData:(NSString *)filename;
- (id)initWithGIFPath:(NSString *)path;
- (void)preparePreviewGIFImage;

@end