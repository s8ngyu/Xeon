#include "XENCommon.h"

@implementation XENTheme

@synthesize name, image;

+ (XENTheme*)themeWithPath:(NSString*)path {
    return [[XENTheme alloc] initWithPath:path];
}

- (UIImage *)getIcon:(NSString *)filename {
    return [self getImage:filename];
}

- (UIImage *)getImage:(NSString *)filename {
    return [UIImage imageWithContentsOfFile:[self getPath:filename]];
}

- (NSString *)getPath:(NSString *)filename {
    return [self.path stringByAppendingPathComponent:filename];
}

- (id)initWithPath:(NSString*)path {
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    if (!exists || !isDir) {
        return nil;
    }
    
    if ((self = [super init])) {
        self.path = path;
        self.name = [[path lastPathComponent] stringByDeletingPathExtension];
    }
    return self;
}

- (void)preparePreviewImage {
    UIImage *previewImage = [self getImage:@"logo@3x.png"];

    if (!previewImage) {
        previewImage = [self getImage:@"logo@2x.png"];
    }
    if (!previewImage) {
        previewImage = [self getImage:@"etched@2x.png"];
    }
    if (!previewImage) {
        previewImage = [self getImage:@"black@2x.png"];
    }
    if (!previewImage) {
        previewImage = [self getImage:@"silver@2x.png"];
    }
    if (!previewImage) {
        previewImage = [self getImage:@"dark@2x.png"];
    }
    if (!previewImage) {
        previewImage = [self getImage:@"light@3x.png"];
    }
    if (!previewImage) {
        previewImage = [self getImage:@"light@2x.png"];
    }

    self.image = previewImage;
}

@end