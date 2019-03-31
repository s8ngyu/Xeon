#import "GIFThemes.h"
#import "XENLeftListController.h"

@interface XENGIFAlignedTableViewCell : UITableViewCell {
}
@end

#define MARGIN 5

@implementation XENGIFAlignedTableViewCell
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect cvf = self.contentView.frame;
    CGFloat width = 60;
    self.imageView.frame = CGRectMake(0.0,
                                      0.0,
                                      width,
                                      cvf.size.height-1);
    self.imageView.contentMode = UIViewContentModeCenter;

    CGRect frame = CGRectMake(width + MARGIN,
                              self.textLabel.frame.origin.y,
                              cvf.size.width - width - 2*MARGIN,
                              self.textLabel.frame.size.height);
    self.textLabel.frame = frame;

    frame = CGRectMake(width + MARGIN,
                       self.detailTextLabel.frame.origin.y,
                       cvf.size.width - width - 2*MARGIN,
                       self.detailTextLabel.frame.size.height);   
    self.detailTextLabel.frame = frame;
}
@end

@implementation XENGIFIconThemesListController

@synthesize themes = _themes;

- (id)initForContentSize:(CGSize)size {
    self = [super init];

    if (self) {
        self.themes = [[NSMutableArray alloc] initWithCapacity:100];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setEditing:NO];
        [_tableView setAllowsSelection:YES];
        [_tableView setAllowsMultipleSelection:NO];
        
        if ([self respondsToSelector:@selector(setView:)])
            [self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];        
    }

    return self;
}

- (void)addThemesFromDirectory:(NSString *)directory {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *diskThemes = [manager contentsOfDirectoryAtPath:directory error:nil];
    
    for (NSString *dirName in diskThemes) {
        NSString *path = [XENGIFThemesDirectory stringByAppendingPathComponent:dirName];
        XENGIFTheme *theme = [XENGIFTheme gifThemeWithPath:path];
        
        if (theme) {
            [theme preparePreviewGIFImage];
            [self.themes addObject:theme];
        }
    }
}

- (void)refreshList {
    self.themes = [[NSMutableArray alloc] initWithCapacity:100];
    [self addThemesFromDirectory: XENGIFThemesDirectory];
            
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"gifName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [self.themes sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    [descriptor release];
    
    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.xeon"];
    selectedTheme = [([file objectForKey:@"GIFTheme"] ?: @"Pac-Man") stringValue];
}

- (id)view {
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"GIF Themes";
    [self refreshList];
}

- (NSArray *)currentThemes {
    return self.themes;
}

- (void)dealloc { 
    self.themes = nil;
    [super dealloc];
}

- (NSString*)navigationTitle {
	return @"GIF Themes";
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentThemes.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeCell"];
    if (!cell) {
        cell = [[XENGIFAlignedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThemeCell"];
    }
    
    XENGIFTheme *theme = [self.currentThemes objectAtIndex:indexPath.row];

    UIImage *resizedImage = [theme.gifImage scaleImageToSize:CGSizeMake(20, 20)];
    cell.textLabel.text = theme.gifName;
    cell.imageView.image = resizedImage;
    cell.imageView.highlightedImage = resizedImage;
    cell.imageView.clipsToBounds = YES;
    cell.selected = NO;

    if ([theme.gifName isEqualToString: selectedTheme] && !tableView.isEditing) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (!tableView.isEditing) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: [[self.currentThemes valueForKey:@"gifName"] indexOfObject: selectedTheme] inSection: 0]];
    if (old) old.accessoryType = UITableViewCellAccessoryNone;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    XENGIFTheme *theme = (XENGIFTheme*)[self.currentThemes objectAtIndex:indexPath.row];
    selectedTheme = theme.gifName;

    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.xeon"];
    [file setObject:selectedTheme forKey:@"GIFTheme"];

    XENLeftListController *parent = (XENLeftListController *)self.parentController;
    [parent setGIFThemeName:selectedTheme];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)XENNotification, nil, nil, true);
}

@end