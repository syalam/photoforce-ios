//
//  LoginViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"
#import "Facebook.h"

@interface LoginViewController : UIViewController <FBSessionDelegate, FBRequestDelegate,FBDialogDelegate> {
    KenBurnsView *kenView;
    NSArray *permissions;
}

-(void)setupKenBurnsView;

@end
