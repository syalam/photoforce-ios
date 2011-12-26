//
//  DetailViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#define ZOOM_STEP 2.0

@implementation DetailViewController



/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }*/

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    fullImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    [fullImageView setBackgroundColor:[UIColor blackColor]];
    captionTextView = [[UITextView alloc]initWithFrame:CGRectMake(120, imageScrollView.frame.size.height - 60, 290, 25)];
    [captionTextView setFont:[UIFont boldSystemFontOfSize:15]];
    [captionTextView setTextColor:[UIColor whiteColor]];
    [captionTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:imageScrollView];
    [imageScrollView addSubview:fullImageView];
    [imageScrollView addSubview:captionTextView];
    
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone-linen"]]];

    captionTapCount = 0;
    
    imageScrollView.minimumZoomScale = 1.0;
    imageScrollView.maximumZoomScale = 6.0;
    imageScrollView.contentSize=CGSizeMake(320, 416);
    imageScrollView.delegate = self;
    
    [imageScrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone-linen"]]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //[singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [imageScrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    //[doubleTap setNumberOfTouchesRequired:2];
    [imageScrollView addGestureRecognizer:doubleTap];
    
    NSURL* myURL = [NSURL URLWithString:urlString];
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:myURL]];
    [fullImageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone-linen"]]];
    fullImageView.image = image;
    fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    [fullImageView setImage:fullImageView.image];
    
    captionTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone-linen"]];
    captionTextView.text = detailCaption;
    
    float minimumScale = [imageScrollView frame].size.width  / [fullImageView frame].size.width;
    [imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setZoomScale:minimumScale];
    
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

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (!tapped) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        tapped = YES;
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        tapped = NO;
    }
    
    
    /*if (captionTapCount > 0 && !zoomed) {
        captionTextView.hidden = NO;
        captionTapCount = 0;
    }
    else {
        captionTextView.hidden = YES;
        captionTapCount ++;
    }*/
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    float newScale;
    if (zoomed) {
        newScale = [imageScrollView zoomScale] / ZOOM_STEP;
        zoomed = NO;;
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

#pragma mark - Rotate Delegate Methods
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [imageScrollView setFrame:CGRectMake(0, 0, 460, 320)];
        [fullImageView setFrame:CGRectMake(0, 0, 460, 320)];
        imageScrollView.contentSize=CGSizeMake(460, 320);
    }
    else if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [imageScrollView setFrame:CGRectMake(0, 0, 320, 460)];
        [fullImageView setFrame:CGRectMake(0, 0, 320, 460)];
        imageScrollView.contentSize=CGSizeMake(320, 460);
    }
    else if (fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [imageScrollView setFrame:CGRectMake(0, 0, 460, 320)];
        [fullImageView setFrame:CGRectMake(0, 0, 460, 320)];
        imageScrollView.contentSize=CGSizeMake(460, 320);
    }
    else {
        [imageScrollView setFrame:CGRectMake(0, 0, 320, 460)];
        [fullImageView setFrame:CGRectMake(0, 0, 320, 460)];
        imageScrollView.contentSize=CGSizeMake(320, 416);
    }
    
}

@end
