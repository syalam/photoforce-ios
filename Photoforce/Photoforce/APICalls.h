//
//  APICalls.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef enum apiCall {
    kAPILogin,
    kAPIGetAlbumCoverURL,
} apiCall;

@interface APICalls : NSObject <PF_FBRequestDelegate> {
    int currentAPICall;
}

@end
