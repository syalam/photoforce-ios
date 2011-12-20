//
//  DetailViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DetailViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *imageScrollView;
    IBOutlet UIImageView *fullImageView;
    IBOutlet UITextView *captionTextView;
    UIImage *image;
    NSString *urlString;
    NSString *detailCaption;
    BOOL zoomed;
    NSUInteger *captionTapCount;
}

- (id)initWithTitle:(NSString *)title URL:(NSString *)url Caption:(NSString *)caption;


@end
