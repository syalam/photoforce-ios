//
//  HomeScreenViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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
    int currentAPICall;
    NSMutableArray *facebookFeedData;
    NSMutableArray *facebookPhotosData;
    NSUInteger imageTag;
    UIActivityIndicatorView* activityIndicator;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL initialLoad;
    BOOL doneLoading;
    
    NSMutableDictionary *imagesDictionary;
    
    dispatch_queue_t imageQueue_;
}
@property(nonatomic,retain) Facebook *facebook;

- (void)playTransitionSoundEffect;
- (void) sendFacebookRequest;
- (UIImage*)imageWithImage:(UIImage*)imageToResize scaledToSize:(CGSize)size;
- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (void)reloadTableViewDataSource;

@end
