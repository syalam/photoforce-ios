//
//  HomeScreenViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

typedef enum apiCall {
    kAPIGraphFeed,
    kAPIGraphPhotos
}apiCall;

@interface HomeScreenViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FBSessionDelegate, FBRequestDelegate,FBDialogDelegate> {
    IBOutlet UITableView *homeTableView;
    IBOutlet UILabel *photoFoceLabel;
    int currentAPICall;
    NSMutableArray *facebookFeedData;
    NSMutableArray *facebookPhotosData;
    NSArray *permissions;
    NSUInteger imageTag;
}
@property(nonatomic,retain) Facebook *facebook;

//- (IBAction)loginButtonClicked:(id)sender;

@end
