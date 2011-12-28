//
//  HomeScreenViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "AppDelegate.h"
#import "AsyncCell.h"
#import "DetailViewController.h"
#import "FlurryAnalytics.h"
#include <AudioToolbox/AudioToolbox.h>

@implementation HomeScreenViewController

@synthesize facebook;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - View Lifecycle

- (void) sendFacebookRequest {
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(120, 200, 100, 100);
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];

    NSString *getUsers = @"{'getUsers':'select uid2 from friend where uid1=me()'";
    NSString *getAlbums = @"'getAlbums':'select aid from album where owner in (select uid2 from #getUsers) order by modified desc limit 100'";
    NSString *getPics = @"'getPics':'select src_big, created, owner, aid from photo where aid in (select aid from #getAlbums) order by created desc limit 1000'}";
    
    NSString *fql = [NSString stringWithFormat:@"%@,%@,%@", getUsers, getAlbums, getPics];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fql, @"q", nil];
    
    [[delegate facebook] requestWithGraphPath:@"fql" andParams:params andHttpMethod:@"GET" andDelegate:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    photoForceLabel.hidden = YES;
    
    [FlurryAnalytics logAllPageViews:self.navigationController];
    
    UIView* customTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    customTitleView.backgroundColor = [UIColor clearColor];
    UILabel* logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    logo.text = @"Photoforce";
    logo.textColor = [UIColor whiteColor];
    logo.shadowColor = [UIColor blackColor];
    logo.shadowOffset = CGSizeMake(1, 1);
    logo.backgroundColor = [UIColor clearColor];
    logo.font = [UIFont fontWithName:@"Zapfino" size:12.0];
    [customTitleView addSubview:logo];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.titleView = customTitleView;
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - homeTableView.bounds.size.height - 20, self.view.frame.size.width, homeTableView.bounds.size.height)];
		refreshView.delegate = self;
        refreshView.backgroundColor = [UIColor clearColor];
		[homeTableView addSubview:refreshView];
		_refreshHeaderView = refreshView;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    homeTableView.dataSource = self;
    homeTableView.delegate = self;
    [homeTableView setSeparatorColor:[UIColor grayColor]];
    homeTableView.center = self.view.center;
    homeTableView.layer.shadowColor = [UIColor blackColor].CGColor;
    homeTableView.layer.shadowOpacity = 0.7f;
    homeTableView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    homeTableView.layer.shadowRadius = 5.0f;
    homeTableView.layer.masksToBounds = NO;
    CGSize size = homeTableView.bounds.size;
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];

    
    imageTag = 1;
    
    [homeTableView setBackgroundColor:[UIColor clearColor]];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgtexture"]]];

    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [delegate facebook].accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    [delegate facebook].expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        homeTableView.hidden = YES;
        [self sendFacebookRequest];
        UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc]initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonClicked:)];
        self.navigationItem.rightBarButtonItem = logOutButton;
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    


}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES;
}

- (void)logOutButtonClicked:(id)sender {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [[delegate facebook]logout:self];
}

#pragma mark - Facebook Delegate Methods

- (void)fbDidLogin {
   AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    // Save updated authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[delegate facebook] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[delegate facebook] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}


- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    [activityIndicator stopAnimating];
    homeTableView.hidden = NO;

    if ([result objectForKey:@"data"]) {
        NSMutableDictionary *resultSetDictionary = [[NSMutableDictionary alloc]initWithDictionary:result];
        facebookPhotosData = [[NSMutableArray alloc]initWithCapacity:1];
        facebookFeedData = [[NSMutableArray alloc]initWithCapacity:1];
        for (id key in resultSetDictionary) {
            facebookPhotosData = [[[resultSetDictionary objectForKey:key]objectAtIndex:2] objectForKey:@"fql_result_set"];
        }
        
    }


    

    [homeTableView reloadData];
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Token: %@", [defaults objectForKey:@"FBAccessTokenKey"]);
}

- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark - UITableViewDatasource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return facebookPhotosData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260.0;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    AsyncCell *cell = (AsyncCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AsyncCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* obj = [facebookPhotosData objectAtIndex:indexPath.row];
    [cell updateCellInfo:obj];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = [[facebookPhotosData objectAtIndex:indexPath.row]objectForKey:@"src_big"];
    NSString *caption = [[facebookPhotosData objectAtIndex:indexPath.row]objectForKey:@"caption"];
    DetailViewController *dvc = [[DetailViewController alloc]initWithTitle:@"Photo" URL:url Caption:caption];
    //[self.navigationController pushViewController:dvc animated:YES];
    
    dvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self.navigationController presentModalViewController:dvc animated:YES];
    [self playTransitionSoundEffect];
}

-(void)playTransitionSoundEffect
{
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("page-flip-4"), CFSTR("wav"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData {
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:homeTableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_reloading) 
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    else
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

// This is the core method you should implement
- (void)reloadTableViewDataSource {
	_reloading = YES;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self sendFacebookRequest];
    
    // Here you would make an HTTP request or something like that
    // Call [self doneLoadingTableViewData] when you are done
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}


- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}




@end
