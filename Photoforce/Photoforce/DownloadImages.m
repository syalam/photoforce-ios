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
@synthesize albumIdArray = _albumIdArray;

- (void)beginDownload {
    _library = [[ALAssetsLibrary alloc] init];
    /*for (int i = 0; i < _albumIdArray.count; i++) {
        //[[PFFacebookUtils facebook]requestWithGraphPath:[NSString stringWithFormat:@"%@/photos", [_albumIdArray objectAtIndex:i]] andDelegate:self];
    }*/
    [[PFFacebookUtils facebook]requestWithGraphPath:@"me/albums" andDelegate:self];
}

#pragma mark - Facebook Request Delegate Methods
- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    NSLog(@"%@", result);
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    
}

@end
