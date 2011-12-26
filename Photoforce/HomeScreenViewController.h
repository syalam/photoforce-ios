//
//  HomeScreenViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "Facebook.h"
#import "JBKenBurnsView.h"

typedef enum apiCall {
    kAPIGraphFeed,
    kAPIGraphPhotos
}apiCall;

@interface HomeScreenViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FBSessionDelegate, FBRequestDelegate,FBDialogDelegate, EGORefreshTableHeaderDelegate> {
    IBOutlet UITableView *homeTableView;
    IBOutlet UILabel *photoFoceLabel;
    int currentAPICall;
    NSMutableArray *facebookFeedData;
    NSMutableArray *facebookPhotosData;
    NSArray *permissions;
    NSUInteger imageTag;
    KenBurnsView *kenView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property(nonatomic,retain) Facebook *facebook;

-(void)setupKenBurnsView;

@end
