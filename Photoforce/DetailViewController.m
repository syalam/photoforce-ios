//
//  DetailViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "FlurryAnalytics.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "FlurryAnalytics.h"
#import "SVProgressHUD.h"

#define ZOOM_STEP 2.0

@implementation DetailViewController
@synthesize imageToDisplay;
@synthesize captionToDisplay;
@synthesize photoObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }

- (IBAction)likeBarButtonItemClicked:(id)sender {
    [SVProgressHUD show];
    apiCall = 1;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:1];
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //PFUser *user = [PFUser currentUser];
    //[delegate facebook].accessToken = [user facebookAccessToken];
    //[delegate facebook].expirationDate = [user facebookExpirationDate];
    NSLog(@"%@", [NSString stringWithFormat:@"%@/likes", [photoObject valueForKey:@"object_id"]]);
    
    if ([[sender title] isEqualToString:@"Like"]) {
        [[delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", [photoObject valueForKey:@"object_id"]]                                           andParams:params andHttpMethod:@"POST" andDelegate:self];
        
        [FlurryAnalytics logEvent:@"LIKE_BUTTON_CLICKED"];
    }
    else
    {
        [[delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", [photoObject valueForKey:@"object_id"]] andParams:params andHttpMethod:@"DELETE" andDelegate:self];
        
        [FlurryAnalytics logEvent:@"UNLIKE_BUTTON_CLICKED"];
    }
    
}

#pragma mark - Facebook Delegate Methods

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result { 
    [SVProgressHUD dismiss];
    if (apiCall == 1) {
        if ([likeBarButtonItem.title isEqualToString:@"Like"]) 
        {
            likeBarButtonItem.title = @"Unlike";
        }
        else
        {
            likeBarButtonItem.title = @"Like";
        }
    }
    else {
        PFUser *user = [PFUser currentUser];
        NSArray *resultArray = [result objectForKey:@"data"];
        for (NSUInteger i = 0; i < resultArray.count; i++) {
            if ([[[resultArray objectAtIndex:i]valueForKey:@"id"]isEqualToString:[user facebookId]]) {
                likeBarButtonItem.title = @"Unlike";
            }
        }
        
    }

}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You need to log out of Facebook and log back in. So sorry!" delegate:self 
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [PFUser logOut];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}


- (id)initWithTitle:(NSString *)title URL:(NSString *)url Caption:(NSString *)caption
{
    self = [super init];
    self.title = title;
    urlString = url;
    detailCaption = caption;
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgtexture"]]];
    [imageScrollView setBackgroundColor:[UIColor clearColor]];
    

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
    
    NSLog(@"%@", photoObject);
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.titleView = customTitleView;
    self.wantsFullScreenLayout = YES;
    
    captionTapCount = 0;
    
    imageScrollView.minimumZoomScale = 1.0;
    imageScrollView.maximumZoomScale = 6.0;
    imageScrollView.contentSize=CGSizeMake(imageToDisplay.size.width, imageToDisplay.size.height);
    imageScrollView.delegate = self;
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    //[doubleTap setNumberOfTouchesRequired:2];
    [imageScrollView addGestureRecognizer:doubleTap];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRight];

    image = self.imageToDisplay;

    [fullImageView setBackgroundColor:[UIColor clearColor]];
    fullImageView.image = image;
    fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    //fullImageView.contentMode = UIViewContentModeScaleAspectFill;
    [fullImageView setImage:fullImageView.image];
    
    fullImageView.center = imageScrollView.center;
    CGSize size = fullImageView.bounds.size;
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
    controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
    controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
    if (![self.captionToDisplay isEqualToString:@""]) {
        NSLog(@"%d", captionToDisplay.length);
        if (captionToDisplay.length > 250) {
            [captionTextView setFrame:CGRectMake(0, 341, 320, 80)];
        }
        else if (captionToDisplay.length > 200) {
            [captionTextView setFrame:CGRectMake(0, 351, 320, 70)];
        }
        else if (captionToDisplay.length > 150) {
            [captionTextView setFrame:CGRectMake(0, 361, 320, 60)];
        }
        else if (captionToDisplay.length > 100) {
            [captionTextView setFrame:CGRectMake(0, 371, 320, 50)];
        }
        else if (captionToDisplay.length > 50) {
            [captionTextView setFrame:CGRectMake(0, 381, 320, 40)];
        }
        else {
            [captionTextView setFrame:CGRectMake(0, 391, 320, 30)];
        }
        captionTextView.text = self.captionToDisplay;
    }
    else {
        captionTextView.hidden = YES;
    }
    
    
    float minimumScale = [imageScrollView frame].size.width  / [fullImageView frame].size.width;
    [imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setZoomScale:minimumScale];
    
     likeBarButtonItem = [[UIBarButtonItem alloc ] initWithTitle:@"Like" 
                                                           style:UIBarButtonItemStyleBordered 
                                                          target:self 
                                                          action:@selector(likeBarButtonItemClicked:)];
    
    self.navigationItem.rightBarButtonItem = likeBarButtonItem;
    
    //make facebook API call to see if this picture has alread been liked by this user
    apiCall = 0;
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [[delegate facebook]requestWithGraphPath:[NSString stringWithFormat:@"%@/likes", [photoObject valueForKey:@"object_id"]]andDelegate:self];
}

- (void)viewDidUnload
{
    likeBarButtonItem = nil;
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

#pragma mark - SrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    //captionTextView.hidden = YES;
    return fullImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [imageScrollView setZoomScale:scale+0.01 animated:NO];
    [imageScrollView setZoomScale:scale animated:NO];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}
/*
- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (!tapped) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        tapped = YES;
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        tapped = NO;
    }
    
}*/

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    float newScale;
    if (zoomed) {
        newScale = [imageScrollView zoomScale] / ZOOM_STEP;
        [imageScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        zoomed = NO;
    }
    else {
        // double tap zooms in
        newScale = [imageScrollView zoomScale] * ZOOM_STEP;
        //captionTextView.hidden = YES;
        zoomed = YES;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleSwipeRight:(UIGestureRecognizer *)gestureRecognizer {
    [FlurryAnalytics logEvent:@"USER_SWIPED_TO_GO_BACK"];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Rotate Delegate Methods
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [imageScrollView setFrame:self.view.frame];
    [fullImageView setFrame:self.view.frame];
    imageScrollView.contentSize = self.view.frame.size;
    
}

#pragma mark - ASIHTTPRequest Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Response %d ==> %@", request.responseStatusCode, [request responseString]);
    
    if ([likeBarButtonItem.title isEqualToString:@"Like"]) 
    {
        likeBarButtonItem.title = @"Unlike";
    }
    else
    {
        likeBarButtonItem.title = @"Like";
    }
}


@end
