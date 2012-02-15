//
//  DetailViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "Facebook.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate,FBRequestDelegate> {
    IBOutlet UIScrollView *imageScrollView;
    IBOutlet UIImageView *fullImageView;
    IBOutlet UITextView *captionTextView;
    UIBarButtonItem* likeBarButtonItem;
    UIImage *image;
    NSString *urlString;
    NSString *detailCaption;
    BOOL zoomed;
    BOOL tapped;
    NSUInteger *captionTapCount;
}
@property (nonatomic, copy) UIImage* imageToDisplay;
@property (nonatomic, copy) NSString* captionToDisplay;
@property (nonatomic, retain) NSDictionary* photoObject;

- (id)initWithTitle:(NSString *)title URL:(NSString *)url Caption:(NSString *)caption;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end
