#import "IconThemes.h"
#import "XENLeftListController.h"

@interface XENAlignedTableViewCell : UITableViewCell {
}
@end

#define MARGIN 5

@implementation XENAlignedTableViewCell
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

@implementation XENIconThemesListController

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
        NSString *path = [XENThemesDirectory stringByAppendingPathComponent:dirName];
        XENTheme *theme = [XENTheme themeWithPath:path];
        
        if (theme) {
            [theme preparePreviewImage];
            [self.themes addObject:theme];
        }
    }
}

- (void)refreshList {
    self.themes = [[NSMutableArray alloc] initWithCapacity:100];
    [self addThemesFromDirectory: XENThemesDirectory];
            
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [self.themes sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    [descriptor release];
    
    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.xeon"];
    selectedTheme = [([file objectForKey:@"IconTheme"] ?: @"Classic Apple") stringValue];
}

- (id)view {
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Themes";
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
	return @"Themes";
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
        cell = [[XENAlignedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThemeCell"];
    }
    
    XENTheme *theme = [self.currentThemes objectAtIndex:indexPath.row];

    UIImage *resizedImage = [theme.image scaleImageToSize:CGSizeMake(20, 20)];
    cell.textLabel.text = theme.name;
    cell.imageView.image = resizedImage;
    cell.imageView.highlightedImage = resizedImage;
    cell.imageView.clipsToBounds = YES;
    cell.selected = NO;

    if ([theme.name isEqualToString: selectedTheme] && !tableView.isEditing) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (!tableView.isEditing) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: [[self.currentThemes valueForKey:@"name"] indexOfObject: selectedTheme] inSection: 0]];
    if (old) old.accessoryType = UITableViewCellAccessoryNone;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    XENTheme *theme = (XENTheme*)[self.currentThemes objectAtIndex:indexPath.row];
    selectedTheme = theme.name;

    HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.xeon"];
    [file setObject:selectedTheme forKey:@"IconTheme"];

    XENLeftListController *parent = (XENLeftListController *)self.parentController;
    [parent setThemeName:selectedTheme];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)XENNotification, nil, nil, true);
}

@end