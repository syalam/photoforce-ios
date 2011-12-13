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
#import "LoginWebViewController.h"

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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SELECT src_big, created, owner FROM photo WHERE aid IN (SELECT aid FROM album WHERE owner IN (SELECT uid2 FROM friend WHERE uid1=me())ORDER BY created DESC) ORDER BY created DESC LIMIT 100",@"q",nil];
    [[delegate facebook] requestWithGraphPath:@"fql" andParams:params andHttpMethod:@"GET" andDelegate:self];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc]initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonClicked:)];
    self.navigationItem.rightBarButtonItem = logOutButton;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    homeTableView.dataSource = self;
    homeTableView.delegate = self;
    
    imageTag = 1;
    

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
        
        self.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *loginButton = [[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonClicked:)];
        self.navigationItem.rightBarButtonItem = loginButton;
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
    [self displayLoggedInItems];
}


- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
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
    return 300.0;    
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



@end
