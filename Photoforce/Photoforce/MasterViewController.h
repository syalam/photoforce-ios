//
//  MasterViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
    
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
