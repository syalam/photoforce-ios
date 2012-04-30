//
//  MasterViewController.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

typedef enum apiCall {
    kAPILogin,
    kAPIGetAlbumCoverURL,
    kAPIGetPhotos,
} apiCall;


@class DetailViewController;

@interface MasterViewController : UITableViewController <PF_FBRequestDelegate> {
    int currentAPICall;
    dispatch_queue_t imageQueue_;
    NSMutableArray *contentArray;
    NSMutableArray *arrayToDisplay;
    NSMutableDictionary *selectedItems;
    NSMutableDictionary *selectedAlbumNameDictionary;
    NSMutableDictionary *imageDictionary;
    NSArray *albumNameArray;
    NSUInteger counter;
}


@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *contentList;
@property (strong, atomic) ALAssetsLibrary* library;

@end
