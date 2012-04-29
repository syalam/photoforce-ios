//
//  MasterViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "SVProgressHUD.h"

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
        //self.title = NSLocalizedString(@"Master", @"Master");
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
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.title = @"Albums";

    /*UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;*/
    
    selectedItems = [[NSMutableDictionary alloc]init];
    
    if (![PFUser currentUser]) {
        DetailViewController *login = [[DetailViewController alloc]initWithNibName:@"DetailViewController_iPhone" bundle:nil];
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:login];
        [self.navigationController presentViewController:navc animated:NO completion:NULL];
    }
    
    else {
        [SVProgressHUD showWithStatus:@"Loading Albums"];
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
            if ([selectedItems objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *albumTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 40)];
            albumTitleLabel.backgroundColor = [UIColor clearColor];
            albumTitleLabel.font = [UIFont boldSystemFontOfSize:14];
            albumTitleLabel.text = [[contentForThisRow objectForKey:@"data"]valueForKey:@"name"];
            
            UIImageView *coverPhotoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 36, 36)];
            coverPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [cell.contentView addSubview:albumTitleLabel];
            [cell.contentView addSubview:coverPhotoImageView];
            
            
            //cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            //cell.textLabel.text = [[contentForThisRow objectForKey:@"data"]valueForKey:@"name"];
            
            //cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            //set a placeholder image while cover images are loading
            if ([imageDictionary objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]) {
                //cell.imageView.image = [UIImage imageWithData:[imageDictionary objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]];
                coverPhotoImageView.image = [UIImage imageWithData:[imageDictionary objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]];

            }
            else {
                //cell.imageView.image = [UIImage imageNamed:@"loadingImage"];
                //asyncronously load cover image using GCD
                dispatch_async(imageQueue_, ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:coverImageURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageDictionary setObject:imageData forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                        //cell.imageView.image = [UIImage imageWithData:imageData];
                        coverPhotoImageView.image = [UIImage imageWithData:[imageDictionary objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]];
                    });
                });
            }
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
    id contentForThisRow = [_contentList objectAtIndex:indexPath.row];
    NSString *albumId = [[contentForThisRow valueForKey:@"data"]valueForKey:@"id"];
    if ([selectedItems objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]]) {
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        [selectedItems removeObjectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    }
    else {
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedItems setObject:albumId forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    }
    
    NSLog(@"%@", contentForThisRow);
    
}


#pragma mark - Facebook Request Delegate Methods
- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
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
            [SVProgressHUD dismiss];
            imageDictionary = [[NSMutableDictionary alloc]init];
            [self.tableView reloadData];
        }
    }
    
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [SVProgressHUD dismissWithError:@"Error"];
}

@end
