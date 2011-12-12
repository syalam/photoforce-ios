//
//  LoginWebViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginWebViewController : UIViewController {
    NSString *loginURL;
}

- (id) initWithTitle:(NSString *)title URL:(NSString*)URL;

@end
