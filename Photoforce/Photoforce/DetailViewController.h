//
//  DetailViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, FBRequestDelegate, FBDialogDelegate,FBSessionDelegate> {
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
