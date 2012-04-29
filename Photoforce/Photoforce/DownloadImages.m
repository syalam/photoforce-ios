//
//  DownloadImages.m
//  Photoforce
//
//  Created by Reyaad Sidique on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadImages.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation DownloadImages
@synthesize library = _library;

- (void)beginDownload {
    _library = [[ALAssetsLibrary alloc] init];
    
}

@end
