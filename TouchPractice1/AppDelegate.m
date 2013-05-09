//
//  AppDelegate.m
//  TouchPractice1
//
//  Created by Samuel Teng on 13/2/25.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkManager.h"

@implementation AppDelegate{
    char                _networkOperationCountDummy;
    
}

@synthesize window;
@synthesize mainViewController;
@synthesize navi,selectedImage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*---------------------------------------------------------------------------*/
    
    /*shake to clear*/
    
    //application.applicationSupportsShakeToEdit = YES;
    
    /*---------------------------------------------------------------------------*/
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    self.mainViewController=[[MainViewController alloc] init];
    self.navi=[[UINavigationController alloc]initWithRootViewController:mainViewController];
    self.window.rootViewController=navi;
    [self.window makeKeyAndVisible];
    return YES;
    
    /*--------------------------------------------------------------------------*/
    
    [[NetworkManager sharedInstance] addObserver:self forKeyPath:@"networkOperationCount" options:NSKeyValueObservingOptionInitial context:&self->_networkOperationCountDummy];
    
    /*-------------------------------------------------------------------------*/
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &self->_networkOperationCountDummy) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = ([NetworkManager sharedInstance].networkOperationCount != 0);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
