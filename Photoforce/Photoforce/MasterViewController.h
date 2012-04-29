//
//  MasterViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

typedef enum apiCall {
    kAPILogin,
    kAPIGetAlbumCoverURL,
} apiCall;


@class DetailViewController;

@interface MasterViewController : UITableViewController <PF_FBRequestDelegate> {
    int currentAPICall;
    dispatch_queue_t imageQueue_;
    NSMutableArray *contentArray;
    NSMutableArray *arrayToDisplay;
    NSMutableDictionary *selectedItems;
    NSMutableDictionary *imageDictionary;
}


@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *contentList;

@end
