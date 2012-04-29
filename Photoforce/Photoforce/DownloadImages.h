//
//  DownloadImages.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Parse/Parse.h>

@interface DownloadImages : NSObject <PF_FBRequestDelegate> {
    
}

@property (strong, atomic) ALAssetsLibrary* library;
@property (nonatomic, retain) NSMutableArray *albumIdArray;

- (void)beginDownload;

@end
