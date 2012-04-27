//
//  DetailViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate> {
    IBOutlet UIButton *loginButton;
}

- (IBAction)loginButtonClicked:(id)sender;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
