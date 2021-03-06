//
//  ExpandableButtonBar.m
//  TouchPractice1
//
//  Created by Samuel Teng on 13/3/12.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "ExpandableButtonBar.h"

@interface ExpandableButtonBar ()

-(void) _expand:(NSDictionary*)properties;
-(void)_close:(NSDictionary*)properties;

@end

@implementation ExpandableButtonBar

@synthesize buttons = _buttons;
@synthesize button = _button;
@synthesize toggleButton = _toggleButton;
@synthesize delegate = _delegate;

-(id)initWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage toggledImage:(UIImage *)toggledIage toggledSelectedImage:(UIImage *)toggledSelectedImage buttons:(NSArray *)buttons center:(CGPoint)center
{
    if (self = [super init]) {
        [self setDefaults];
        
        //Reverse buttons so it makes since for top/bottom
        NSArray *reversedButtons = [[buttons reverseObjectEnumerator] allObjects];
        [self setButtons:reversedButtons];
        
        //Button location/size settings
        CGRect buttonFrame = CGRectMake(0, 0, [image size].width, [image size].height);
        CGPoint buttonCenter = CGPointMake([image size].width/2.0f, [image size].height);
        
        UIButton *defaultButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [defaultButton setCenter:buttonCenter];
        [defaultButton setImage:image forState:UIControlStateNormal];
        [defaultButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [self setButton:defaultButton];
        
        UIButton *toggledButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [toggledButton setCenter:buttonCenter];
        [toggledButton setImage:image forState:UIControlStateNormal];
        [toggledButton addTarget:self action:@selector(onToggledButton:) forControlEvents:UIControlEventTouchUpInside];
        //Init invisible
        [toggledButton setAlpha:0.0f];
        [self setToggleButton:toggledButton];
        
        for (int i = 0; i < [buttons count]; ++i) {
            UIButton *button = (UIButton*)[buttons objectAtIndex:i];
            [button addTarget:self action:@selector(explode:) forControlEvents:UIControlEventTouchUpInside];
            [button setCenter:buttonCenter];
            [button setAlpha:0.0f];
            [self addSubview:button];
        }
        
        //container view settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFrame:buttonFrame];
        [self setCenter:center];
        
        [self addSubview:[self button]];
        [self addSubview:[self toggleButton]];
    }
    return self;
}


-(void) setDefaults
{
    _fadeTime = 0.2f;
    _animationTime = 0.4f;
    _padding = 15.0f;
    _far = 15.0f;
    _near = 7.0f;
    _delay = 0.1f;
    
    _toggled = NO;
    _spin = NO;
    _horizontal = NO;
    _animated = YES;
}

-(void) onButton:(id)sender
{
    [self showButtonsAnimated:_animated];
}


-(void)onToggledButton:(id)sender
{
    [self hideButtonsAnimated:_animated];
}


-(void)showButtons
{
    [self showButtonsAnimated:NO];
}

-(void)hideButtons
{
    [self hideButtonsAnimated:NO];
}

-(void) toggleMainButton
{
    UIButton *animateTo;
    UIButton *animateFrom;
    
    if (_toggled) {
        animateTo = [self button];
        animateFrom = [self toggleButton];
    }else{
        animateTo = [self toggleButton];
        animateFrom = [self button];
    }
    [UIView animateWithDuration:_fadeTime animations:^{
        [animateTo setAlpha:1.0f];
        [animateFrom setAlpha:0.0f];
    }];
}

-(void) explode:(id)sender
{
    if (! _explode)return;
    UIView *view = (UIView*)sender;
    CGAffineTransform scale = CGAffineTransformMakeScale(5.0f, 5.0f);
    CGAffineTransform unScale = CGAffineTransformMakeScale(1.0f, 1.0f);
    [UIView animateWithDuration:0.3 animations:^{
        [view setAlpha:0.0f];
        [view setTransform:scale];
    } completion:^(BOOL finished) {
        [view setAlpha:1.0f];
        [view setTransform:unScale];
    }];
}

- (void) showButtonsAnimated:(BOOL)animated
{
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(expandingBarWillAppear:)]) {
        [[self delegate] expandingBarWillAppear:self];
    }
    float y = [[self button] center].y;
    float x = [[self button] center].x;
    float endY = y;
    float endX = x;
    for (int i = 0; i < [[self buttons] count]; ++i) {
        UIButton *button = [[self buttons] objectAtIndex:i];
        endY -= [self getYOffset:button];
        endX += [self getXOffset:button];
        float farY = endY - ( ! _horizontal ? _far : 0.0f);
        float farX = endX - (_horizontal ? _far : 0.0f);
        float nearY = endY + ( ! _horizontal ? _near : 0.0f);
        float nearX = endX + (_horizontal ? _near : 0.0f);
        if (animated) {
            NSMutableArray *animationOptions = [NSMutableArray array];
            if (_spin) {
                CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
                [rotateAnimation setValues:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * 2], nil]];
                [rotateAnimation setDuration:_animationTime];
                [rotateAnimation setKeyTimes:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil]];
                [animationOptions addObject:rotateAnimation];
            }
            
            CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            [positionAnimation setDuration:_animationTime];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, x, y);
            CGPathAddLineToPoint(path, NULL, farX, farY);
            CGPathAddLineToPoint(path, NULL, nearX, nearY);
            CGPathAddLineToPoint(path, NULL, endX, endY);
            [positionAnimation setPath: path];
            CGPathRelease(path);
            
            [animationOptions addObject:positionAnimation];
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            [animationGroup setAnimations: animationOptions];
            [animationGroup setDuration:_animationTime];
            [animationGroup setFillMode: kCAFillModeForwards];
            [animationGroup setTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            
            NSDictionary *properties = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:button, [NSValue valueWithCGPoint:CGPointMake(endX, endY)], animationGroup, nil] forKeys:[NSArray arrayWithObjects:@"view", @"center", @"animation", nil]];
            [self performSelector:@selector(_expand:) withObject:properties afterDelay:_delay * ([[self buttons] count] - i)];
        }
        else {
            [button setCenter:CGPointMake(x, y)];
            [button setAlpha:1.0f];
        }
    }
    _toggled = NO;
    [self toggleMainButton];
    float delegateDelay = _animated ? [[self buttons] count] * _delay + _animationTime : 0.0f;
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(expandingBarDidAppear:)]) {
        [[self delegate] performSelector:@selector(expandingBarDidAppear:) withObject:self afterDelay:delegateDelay];
    }
}

- (void) hideButtonsAnimated:(BOOL)animated
{
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(expandingBarWillDisappear:)]) {
        [[self delegate] performSelector:@selector(expandingBarWillDisappear:) withObject:self];
    }
    CGPoint center = [[self button] center];
    float endY = center.y;
    float endX = center.x;
    for (int i = 0; i < [[self buttons] count]; ++i) {
        UIButton *button = [[self buttons] objectAtIndex:i];
        if (animated) {
            NSMutableArray *animationOptions = [NSMutableArray array];
            if (_spin) {
                CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
                [rotateAnimation setValues:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * -2], nil]];
                [rotateAnimation setDuration:_animationTime];
                [rotateAnimation setKeyTimes:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil]];
                [animationOptions addObject:rotateAnimation];
            }
            
            CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            [opacityAnimation setValues:[NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:0.0f], nil]];
            [opacityAnimation setDuration:_animationTime];
            [animationOptions addObject:opacityAnimation];
            
            float y = [button center].y;
            float x = [button center].x;
            CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            [positionAnimation setDuration:_animationTime];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, x, y);
            CGPathAddLineToPoint(path, NULL, endX, endY);
            [positionAnimation setPath: path];
            CGPathRelease(path);
            
            [animationOptions addObject:positionAnimation];
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            [animationGroup setAnimations: animationOptions];
            [animationGroup setDuration:_animationTime];
            [animationGroup setFillMode: kCAFillModeForwards];
            [animationGroup setTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            
            NSDictionary *properties = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:button, animationGroup, nil] forKeys:[NSArray arrayWithObjects:@"view", @"animation", nil]];
            [self performSelector:@selector(_close:) withObject:properties afterDelay:_delay * ([[self buttons] count] - i)];
        }
        else {
            [button setCenter:center];
            [button setAlpha:0.0f];
        }
    }
    float delegateDelay = _animated ? [[self buttons] count] * _delay + _animationTime: 0.0f;
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(expandingBarDidDisappear:)]) {
        [[self delegate] performSelector:@selector(expandingBarDidDisappear:) withObject:self afterDelay:delegateDelay];
    }
    _toggled = YES;
    [self toggleMainButton];
}

- (void) _expand:(NSDictionary*)properties
{
    UIView *view = [properties objectForKey:@"view"];
    CAAnimationGroup *animationGroup = [properties objectForKey:@"animation"];
    NSValue *val = [properties objectForKey:@"center"];
    CGPoint center = [val CGPointValue];
    [[view layer] addAnimation:animationGroup forKey:@"Expand"];
    [view setCenter:center];
    [view setAlpha:1.0f];
}

- (void) _close:(NSDictionary*)properties
{
    UIView *view = [properties objectForKey:@"view"];
    CAAnimationGroup *animationGroup = [properties objectForKey:@"animation"];
    CGPoint center = [[self button] center];
    [[view layer] addAnimation:animationGroup forKey:@"Collapse"];
    [view setAlpha:0.0f];
    [view setCenter:center];
}

- (int) getXOffset:(UIView*)view
{
    if (_horizontal) {
        return [view frame].size.height + _padding;
    }
    return 0;
}

- (int) getYOffset:(UIView*)view
{
    if ( ! _horizontal) {
        return [view frame].size.height + _padding;
    }
    return 0;
}

/* ----------------------------------------------
 * You probably do not want to edit anything under here
 * --------------------------------------------*/
- (void) setAnimationTime:(float)time
{
    if (time > 0) {
        _animationTime = time;
    }
}

- (void) setFadeTime:(float)time
{
    if (time > 0) {
        _fadeTime = time;
    }
}

- (void) setPadding:(float)padding
{
    if (padding > 0) {
        _padding = padding;
    }
}

- (void) setSpin:(BOOL)b
{
    _spin = b;
}

- (void) setHorizontal:(BOOL)b
{
    NSArray *reversedButtons = [[[self buttons] reverseObjectEnumerator] allObjects];
    [self setButtons:reversedButtons];
    
    _horizontal = b;
}

- (void) setFar:(float)num
{
    _far = num;
}

- (void) setNear:(float)num
{
    _near = num;
}

- (void) setDelay:(float)num
{
    _delay = num;
}

- (void) setExplode:(BOOL)b
{
    _explode = b;
}

/* ----------------------------------------------
 * DO NOT CHANGE
 * The following is a hack to allow touches outside
 * of this view. Use caution when changing.
 * --------------------------------------------*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = nil;
    v = [super hitTest:point withEvent:event];
    return v;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [super pointInside:point withEvent:event];
    if (YES == isInside) {
        return isInside;
    }
    for (UIButton *button in [self buttons]) {
        CGPoint inButtonSpace = [self convertPoint:point toView:button];
        BOOL isInsideButton = [button pointInside:inButtonSpace withEvent:nil];
        if (YES == isInsideButton) {
            return isInsideButton;
        }
    }
    return isInside;
}

@end
