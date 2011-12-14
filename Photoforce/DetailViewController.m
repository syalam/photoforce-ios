//
//  DetailViewController.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    [view setBackgroundColor:[UIColor blackColor]];
    self.view = view;
    fullImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    [fullImageView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:fullImageView];

}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
