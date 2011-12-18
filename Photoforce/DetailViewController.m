//
//  DetailViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#define ZOOM_STEP 1.5

@implementation DetailViewController



/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (id)initWithTitle:(NSString *)title URL:(NSString *)URL
{
    self = [super init];
    self.title = title;
    urlString = URL;
    return self;
}




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 415)];
    self.view = view;
    fullImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    [fullImageView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:scrollView];
    [scrollView addSubview:fullImageView];

}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 6.0;
    scrollView.contentSize=CGSizeMake(320, 416);
    scrollView.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [scrollView addGestureRecognizer:doubleTap];
    
    NSURL* myURL = [NSURL URLWithString:urlString];
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:myURL]];
    fullImageView.image = image;
    fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    [fullImageView setImage:fullImageView.image];

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

#pragma mark - SrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return fullImageView;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = [scrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}


@end
