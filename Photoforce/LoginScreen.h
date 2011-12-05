//
//  LoginScreen.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface LoginScreen : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, FBSessionDelegate> {
    IBOutlet UIButton *loginButton;
    IBOutlet UITextField *userNameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIScrollView *scrollView;
    NSArray *permissions;
    
    Facebook *facebook;
}
@property (nonatomic, retain) Facebook *facebook;

- (IBAction)loginButtonClicked:(id)sender;




@end
