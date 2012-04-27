//
//  AppDelegate.h
//  Photoforce
//
//  Created by Reyaad Sidique on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    Facebook *facebook;
    NSMutableDictionary *userPermissions;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) NSMutableDictionary *userPermissions;

@end
