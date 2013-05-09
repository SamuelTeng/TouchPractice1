//
//  AppDelegate.h
//  TouchPractice1
//
//  Created by Samuel Teng on 13/2/25.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIImage *selectedImage;
}

@property(nonatomic,strong)UIWindow *window;
@property(nonatomic,strong)UINavigationController *navi;
@property(nonatomic,strong)MainViewController *mainViewController;

/*setting these two properties in order to allow all viewControllers sending objects to rootViewController since AppDelegat works as a middle station for all viewControllers include root one*/

@property(nonatomic,strong)UIImage *selectedImage;
@property(nonatomic,strong)UIImage *pantsSelectedImage;

@end
