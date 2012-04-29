//
//  DownloadImages.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DownloadImages : NSObject {
    
}

@property (strong, atomic) ALAssetsLibrary* library;

- (void)beginDownload;

@end
