//
//  AppDelegate.h
//  Photoforce
//
//  Created by Reyaad Sidique on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate> {
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSMutableDictionary *userPermissions;
@property (strong, nonatomic) UINavigationController *navigationController;

@end
