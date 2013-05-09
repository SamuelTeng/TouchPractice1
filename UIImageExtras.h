//
//  UIImageExtras.h
//  TouchPractice
//
//  Created by Samuel Teng on 13/2/22.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(Extras)

-(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
@end
