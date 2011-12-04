//
//  LoginScreen.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginScreen.h"

@implementation LoginScreen

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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    userNameTextField.delegate = self;
    passwordTextField.delegate = self;
    UIGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMethod:)];
    [(UITapGestureRecognizer *)recognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:recognizer];
    recognizer.delegate = self;
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self performSelector:@selector(scrollScreen:) withObject:nil afterDelay:0.1];
}
     
-(void)scrollScreen:(id)sender {
    scrollView.contentSize = CGSizeMake(320, 500);
    CGPoint bottomOffeset = CGPointMake(0, 140);
    [scrollView setContentOffset:bottomOffeset animated:YES];
}

-(void)scrollScreenBack {
    CGPoint bottomOffset = CGPointMake(0, 0);
    [scrollView setContentOffset: bottomOffset animated: YES];
}

-(void)tapMethod:(id)sender {
    [userNameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [self scrollScreenBack];
    //[scrollView resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == loginButton || touch.view == self.view)) {
        return NO;
    }
    return YES;
}

- (IBAction)loginButtonClicked:(id)sender {
    facebook = [[Facebook alloc] initWithAppId:@"266617523389474" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }
}

/*- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}*/


@end
