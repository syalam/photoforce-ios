//
//  APICalls.m
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APICalls.h"

@implementation APICalls


#pragma mark - Facebook Request Delegate Methods
- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    
    if (currentAPICall == kAPILogin) {
        currentAPICall = kAPIGetAlbumCoverURL;
        //NSArray *fbDataArray = [result valueForKey:@"data"];
        
        
    }
    else if (currentAPICall == kAPIGetAlbumCoverURL) {
        NSLog(@"%@", result);
    }
    
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}


@end
