//
//  UIView-Transform.m
//  TouchPractice
//
//  Created by Samuel Teng on 13/2/20.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "UIView-Transform.h"

@implementation UIView(Transform)

-(CGFloat) rotation
{
    CGAffineTransform t = self.transform;
    return atan2f(t.b, t.a);
}

-(CGFloat) xscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

-(CGFloat) yscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.b * t.b + t.d * t.d);
}

@end
