//
//  main.m
//  Photoforce
//
//  Created by Reyaad Sidique on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    [Parse setApplicationId:@"DzxqoqQythxGkL5GzJdDI38kNL6kNxNAxsHwnsiC" 
                  clientKey:@"agksFfP0HM4q5RO4QR9iicqpw5qL3BdEeval2Gv8"];

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
