//
//  DLHistoryLIstViewController.m
//  DreamLand
//
//  Created by ricky on 13-6-5.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLHistoryListViewController.h"

static NSString *searchPath = nil;


@interface DLHistoryListViewController ()
@property (nonatomic, retain) NSArray *fileArray;
- (NSArray*)loadDatFiles;
@end

@implementation DLHistoryListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)reload
{
    [self.spinnerView startAnimating];
    [self performSelectorOnMainThread:@selector(doLoadItems)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)doLoadItems
{
    self.fileArray = [self loadDatFiles];
    [self.tableView reloadData];
    [self.spinnerView stopAnimating];
}

- (NSArray*)loadDatFiles
{
    if (!searchPath) {
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        searchPath = [[arr lastObject] retain];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *list = [fm contentsOfDirectoryAtPath:searchPath
                                            error:&error];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:list.count];
    if (!error) {
        for (NSString *file in list) {
            if (![file.pathExtension isEqualToString:@"dat"])
                continue;
            NSString *fullPath = [searchPath stringByAppendingPathComponent:file];
            NSDictionary *attr = [fm attributesOfItemAtPath:fullPath
                                                      error:&error];
            if (![[attr objectForKey:NSFileType] isEqualToString:NSFileTypeRegular])
                continue;
            NSNumber *size = [attr objectForKey:NSFileSize];
            NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                                  fullPath, @"path",size,@"size", nil];
            [result addObject:item];
        }
        return [NSArray arrayWithArray:result];
    }
    return nil;
}

#pragma mark - Actions

- (IBAction)onCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.fileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *item = [self.fileArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [[item valueForKey:@"path"] lastPathComponent];
    cell.detailTextLabel.text = [[item objectForKey:@"size"] stringValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(historyList:didSelectFile:)])
        [self.delegate historyList:self
                     didSelectFile:[[self.fileArray objectAtIndex:indexPath.row] valueForKey:@"path"]];
}

@end
