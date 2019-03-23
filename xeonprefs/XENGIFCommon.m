#include "XENGIFCommon.h"

@implementation XENGIFTheme

@synthesize gifName, gifImage;

+ (XENGIFTheme*)gifThemeWithPath:(NSString*)path {
    return [[XENGIFTheme alloc] initWithGIFPath:path];
}

- (UIImage *)getGIFIcon:(NSString *)filename {
    return [self getGIFImage:filename];
}

- (UIImage *)getGIFImage:(NSString *)filename {
    return [UIImage imageWithContentsOfFile:[self getGIFPath:filename]];
}

- (NSString *)getGIFPath:(NSString *)filename {
    return [self.gifPath stringByAppendingPathComponent:filename];
}

- (NSData *)getGIFData:(NSString *)filename {
    NSString *imgPath = [self.gifPath stringByAppendingPathComponent:filename];
    NSData *gifData = [NSData dataWithContentsOfFile:imgPath];

    return gifData;
}

- (id)initWithGIFPath:(NSString*)path {
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    if (!exists || !isDir) {
        return nil;
    }
    
    if ((self = [super init])) {
        self.gifPath = path;
        self.gifName = [[path lastPathComponent] stringByDeletingPathExtension];
    }
    return self;
}

- (void)preparePreviewGIFImage {
    UIImage *previewImage = [self getGIFImage:@"animated.gif"];

    self.gifImage = previewImage;
}

@end