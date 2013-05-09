//
//  DragView.h
//  TouchPractice
//
//  Created by Samuel Teng on 13/2/20.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView-Transform.h"

@interface DragView : UIImageView<UIGestureRecognizerDelegate>{
    
    CGFloat tx; // x translation
	CGFloat ty; // y translation
	CGFloat scale; // zoom scale
	CGFloat theta; // rotation angle
    CGPoint previousLocation;
}

@property (nonatomic,strong) UIViewController *viewController;



@end
