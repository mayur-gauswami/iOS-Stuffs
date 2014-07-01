//
//  AppDelegate.m
//  webviewTest
//
//  Created by Mayur Gosai on 24/04/14.
//  Copyright (c) 2014 Mayur Gosai. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/objc-runtime.h>
#import "UIView+Custom.m"
#import "JRSwizzle.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //methodSwizzle([UIView class], @selector(addGestureRecognizer:), @selector(myAddGestureRecognizer:));
    //[UIView jr_swizzleMethod:@selector(myAddGestureRecognizer:) withMethod:@selector(addGestureRecognizer:) error:NULL];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

void methodSwizzle(Class c, SEL swizzledSelector, SEL swizzlingSelector)
{
    BOOL isClassMethod=NO;
    Method swizzledMETHOD=class_getInstanceMethod(c, swizzledSelector);
    if(swizzledMETHOD == NULL)
    {
        //Try class method
        swizzledMETHOD=class_getClassMethod(c, swizzledSelector);
        if(swizzledMETHOD == NULL)
        {
            NSLog(@"Neither class or instance method swizzledSelector=%s exists for %@",(char*)swizzledSelector,c);
            return;
        }
        isClassMethod=YES;
    }
    Method swizzlingMETHOD;
    if(isClassMethod)
    {
        swizzlingMETHOD=class_getClassMethod(c, swizzlingSelector);
        if(swizzlingMETHOD == NULL)
        {
            NSLog(@"class method swizzlingSelector= %s does not exist in class %@",(char*)swizzlingSelector,c);
            return;
        }
    }
    else {
        swizzlingMETHOD=class_getInstanceMethod(c, swizzlingSelector);
        if(swizzlingMETHOD == NULL)
        {
            NSLog(@"instance method swizzlingSelector= %s does not exist in class %@",(char*)swizzlingSelector,c);
            return;
        }
    }
    
    method_exchangeImplementations(swizzledMETHOD, swizzlingMETHOD);
}

@end