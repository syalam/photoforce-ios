//
//  LoginViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "JBKenBurnsView.h"
#import "HomeScreenViewController.h"
#import "FlurryAnalytics.h"
#import <Parse/Parse.h>

@implementation LoginViewController

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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*UIView* customTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
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
    self.navigationItem.titleView = customTitleView;*/
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [self setupKenBurnsView];
    
    logo.text = @"Photoforce";
    logo.textColor = [UIColor whiteColor];
    logo.shadowColor = [UIColor blackColor];
    logo.shadowOffset = CGSizeMake(1, 1);
    logo.backgroundColor = [UIColor clearColor];
    logo.font = [UIFont fontWithName:@"Zapfino" size:30.0];
    
    [self.view addSubview:logo];
    
    PFUser *user = [PFUser currentUser];
    
    [delegate facebook].accessToken = [user facebookAccessToken];
    [delegate facebook].expirationDate = [user facebookExpirationDate];
    
    if ([user facebookAccessToken] 
        && [user facebookExpirationDate]) {
        HomeScreenViewController *homeScreen = [[HomeScreenViewController alloc]initWithNibName:@"HomeScreenViewController" bundle:nil];
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:homeScreen];
        [self.navigationController presentModalViewController:navc animated:NO];
    }
        
    slideToCancel = [[SlideToCancelViewController alloc] init];
    slideToCancel.delegate = self;
    CGRect sliderFrame = slideToCancel.view.frame;
    sliderFrame.origin.y = self.view.frame.size.height;
    slideToCancel.view.frame = sliderFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add slider to the view
    [self.view addSubview:slideToCancel.view];
    
    slideToCancel.enabled = YES;
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	CGPoint sliderCenter = slideToCancel.view.center;
	//sliderCenter.y -= slideToCancel.view.bounds.size.height;
    sliderCenter.y = self.view.frame.size.height - 40;
	slideToCancel.view.center = sliderCenter;
	[UIView commitAnimations];
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

-(void)setupKenBurnsView
{
    kenView = [[KenBurnsView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    kenView.layer.borderWidth = 1;
    kenView.layer.borderColor = [UIColor blackColor].CGColor;  
    [self.view addSubview:kenView];
    
    NSArray *myImages = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"image1.jpeg"],
                         [UIImage imageNamed:@"image2.jpeg"],
                         [UIImage imageNamed:@"image3.png"],
                         [UIImage imageNamed:@"image4.png"],
                         [UIImage imageNamed:@"image5.png"], nil];
    
    [kenView animateWithImages:myImages 
            transitionDuration:15
                          loop:YES 
                   isLandscape:YES];
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

#pragma mark - Facebook Delegate Methods

- (void)fbDidLogin {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    // Save updated authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[delegate facebook] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[delegate facebook] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
        
    HomeScreenViewController *homeScreen = [[HomeScreenViewController alloc]initWithNibName:@"HomeScreenViewController" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:homeScreen];
    [self.navigationController presentModalViewController:navc animated:NO];
    //[self.navigationController pushViewController:homeScreen animated:YES];
    
}

#pragma mark - Slider Delegate Method
- (void) cancelled {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    permissions = [[NSArray alloc] initWithObjects:@"offline_access", @"read_stream", @"user_photos",@"friends_photos", nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [PFUser logInWithFacebook:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Login" message:@"Please Try Again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            [defaults setObject:[user facebookAccessToken] forKey:@"FBAccessTokenKey"];
            [defaults setObject:[user facebookExpirationDate] forKey:@"FBExpirationDateKey"];
            [delegate facebook].accessToken = [user facebookAccessToken];
            [delegate facebook].expirationDate = [user facebookExpirationDate];
            
            HomeScreenViewController *homeScreen = [[HomeScreenViewController alloc]initWithNibName:@"HomeScreenViewController" bundle:nil];
            UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:homeScreen];
            [self.navigationController presentModalViewController:navc animated:NO];
        }
    }];
}



@end
