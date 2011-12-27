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
#import "JBKenBurnsView.h"

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void) displayLoggedInItems {
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    homeTableView.hidden = NO;
    photoFoceLabel.hidden = YES;
    currentAPICall = kAPIGraphFeed;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(120, 200, 100, 100);
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    homeTableView.hidden = YES;
    
    //NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SELECT src_big, created, owner, aid FROM photo WHERE aid IN (SELECT aid FROM album WHERE owner = me() or owner IN (SELECT uid2 FROM friend WHERE uid1=me())) ORDER BY created DESC LIMIT 30",@"q",nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SELECT src_big, created, modified, owner, aid, caption FROM photo WHERE aid IN (SELECT aid, modified FROM album WHERE owner IN (SELECT uid2 FROM friend WHERE uid1=me() or uid2 = me())order by modified desc) ORDER BY created DESC LIMIT 1000",@"q",nil];
    
    /*
    NSString *getPictures = @"{'getPics':'SELECT src_big, created, owner, aid FROM photo WHERE aid IN (SELECT aid FROM album WHERE owner IN (SELECT uid2 FROM friend WHERE uid1=me())ORDER BY created DESC) ORDER BY created DESC LIMIT 100'";
    NSString *getAlbumNames = @"'getAlbumNames':'SELECT name FROM album WHERE aid in (SELECT aid FROM #getPics)'}";
    NSString *fql = [NSString stringWithFormat:@"%@,%@", getPictures, getAlbumNames];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fql, @"q", nil];
     */
    [[delegate facebook] requestWithGraphPath:@"fql" andParams:params andHttpMethod:@"GET" andDelegate:self];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc]initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonClicked:)];
    self.navigationItem.rightBarButtonItem = logOutButton;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [FlurryAnalytics logAllPageViews:self.navigationController];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - homeTableView.bounds.size.height, self.view.frame.size.width, homeTableView.bounds.size.height)];
		refreshView.delegate = self;
        refreshView.backgroundColor = [UIColor clearColor];
		[homeTableView addSubview:refreshView];
		_refreshHeaderView = refreshView;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    homeTableView.dataSource = self;
    homeTableView.delegate = self;
    
    imageTag = 1;
    
    //[homeTableView setBackgroundColor:[UIColor blackColor]];
    [homeTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone-linen"]]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone-linen"]]];
    
    

    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [delegate facebook].accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
    [delegate facebook].expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        [self displayLoggedInItems];
    }
    else {
        homeTableView.hidden = YES;
        [self setupKenBurnsView];
        self.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *loginButton = [[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonClicked:)];
        self.navigationItem.rightBarButtonItem = loginButton;
    }
    
}


-(void)setupKenBurnsView
{
    kenView = [[KenBurnsView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    kenView.layer.borderWidth = 1;
    kenView.layer.borderColor = [UIColor blackColor].CGColor;  
    [self.view addSubview:kenView];
    
    NSArray *myImages = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"image1.jpeg"],
                         [UIImage imageNamed:@"image2.jpeg"],
                         [UIImage imageNamed:@"image3.jpeg"],
                         [UIImage imageNamed:@"image4.png"],
                         [UIImage imageNamed:@"image5.png"], nil];
    
    [kenView animateWithImages:myImages 
                 transitionDuration:15
                               loop:YES 
                        isLandscape:YES];
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


#pragma mark - Button Clicks

- (void)loginButtonClicked:(id)sender {
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    permissions = [[NSArray alloc] initWithObjects:@"offline_access", @"read_stream", @"user_photos",@"friends_photos", nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        [delegate facebook].accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        [delegate facebook].expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![[delegate facebook] isSessionValid]) {
        [delegate facebook].sessionDelegate = self;
        [[delegate facebook] authorize:permissions];
    }
    
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
    homeTableView.hidden = NO;
    [kenView removeFromSuperview];
    [self displayLoggedInItems];
}


- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    [activityIndicator stopAnimating];
    homeTableView.hidden = NO;
    
    facebookPhotosData = [[NSMutableArray alloc]initWithCapacity:1];
    if ([result objectForKey:@"data"]) {
        facebookPhotosData = [result objectForKey:@"data"];
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
        homeTableView.hidden = YES;
        photoFoceLabel.hidden = NO;
        self.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *loginButton = [[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonClicked:)];
        self.navigationItem.rightBarButtonItem = loginButton;
        
        [self setupKenBurnsView];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

// This is the core method you should implement
- (void)reloadTableViewDataSource {
	_reloading = YES;
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SELECT src_big, created, modified, owner, aid, caption FROM photo WHERE aid IN (SELECT aid, modified FROM album WHERE owner IN (SELECT uid2 FROM friend WHERE uid1=me() or uid2 = me())order by modified desc) ORDER BY created DESC LIMIT 1000",@"q",nil];
    [[delegate facebook] requestWithGraphPath:@"fql" andParams:params andHttpMethod:@"GET" andDelegate:self];
    
    // Here you would make an HTTP request or something like that
    // Call [self doneLoadingTableViewData] when you are done
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}


- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}




@end
