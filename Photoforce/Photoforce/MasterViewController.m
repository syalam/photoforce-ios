//
//  MasterViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize contentList = _contentList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    if (![PFUser currentUser]) {
        DetailViewController *login = [[DetailViewController alloc]initWithNibName:@"DetailViewController_iPhone" bundle:nil];
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:login];
        [self.navigationController presentViewController:navc animated:NO completion:NULL];
    }
    
    else {
        arrayToDisplay = [[NSMutableArray alloc]init];
        imageQueue_ = dispatch_queue_create("com.tappforce.photoforce.imageQueue", NULL);
        currentAPICall = kAPILogin;
        [[PFFacebookUtils facebook]requestWithGraphPath:@"me/albums" andDelegate:self];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentList.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id contentForThisRow = [_contentList objectAtIndex:indexPath.row];
    NSArray *imagesArray = [[[_contentList objectAtIndex:indexPath.row]valueForKey:@"coverImage"]valueForKey:@"images"];
    NSURL *coverImageURL = [NSURL URLWithString:[[imagesArray objectAtIndex:6]valueForKey:@"source"]];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.textLabel.text = [[contentForThisRow objectForKey:@"data"]valueForKey:@"name"];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.image = [UIImage imageNamed:@"loadingImage"];
            dispatch_async(imageQueue_, ^{
                NSData *imageData = [NSData dataWithContentsOfURL:coverImageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData:imageData];
                });
            });
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - Facebook Request Delegate Methods
- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    
    if (currentAPICall == kAPILogin) {
        currentAPICall = kAPIGetAlbumCoverURL;
        contentArray = [result valueForKey:@"data"];
        for (NSUInteger i = 0; i < contentArray.count; i++) {
            [[PFFacebookUtils facebook]requestWithGraphPath:[[contentArray objectAtIndex:i]valueForKey:@"cover_photo"] andDelegate:self];
        }
        
    }
    else if (currentAPICall == kAPIGetAlbumCoverURL) {
        NSDictionary *resultDictionary = result;
        NSMutableDictionary *objectsToDisplay = [[NSMutableDictionary alloc]init];
        for (NSUInteger i = 0; i < contentArray.count; i++) {
            if ([[[contentArray objectAtIndex:i]valueForKey:@"cover_photo"]isEqualToString:[resultDictionary valueForKey:@"id"]]) {
                [objectsToDisplay setObject:[contentArray objectAtIndex:i] forKey:@"data"];
                [objectsToDisplay setObject:resultDictionary forKey:@"coverImage"];
                [arrayToDisplay addObject:objectsToDisplay];
            }
        }
        [self setContentList:arrayToDisplay];
        
        //check if all items have been added to the array before reloading the tableview
        if (arrayToDisplay.count == contentArray.count) {
            [self.tableView reloadData];
        }
    }
    
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
