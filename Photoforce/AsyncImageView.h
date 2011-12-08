//
//  AsyncImageView.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIView {
    NSURLConnection* connection;
    NSMutableData* data;
}

- (void)loadImageFromURL:(NSURL*)url;
- (UIImage*) image;

@end
