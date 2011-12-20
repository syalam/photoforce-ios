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
    UIView *view;
    UIScrollView *imageScrollView;
    UIImageView *fullImageView;
    UIImage *image;
    UITextView *captionTextView;
    NSString *urlString;
    NSString *detailCaption;
    NSUInteger *tapCount;
}

- (id)initWithTitle:(NSString *)title URL:(NSString *)url Caption:(NSString *)caption;


@end
