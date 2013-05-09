//
//  DragView.m
//  TouchPractice
//
//  Created by Samuel Teng on 13/2/20.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "DragView.h"

@implementation DragView

@synthesize viewController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Promote the touched view
    [self.superview bringSubviewToFront:self];
    
    // initialize translation offsets
    tx = self.transform.tx;
    ty = self.transform.ty;
    
    // Remember original location
    previousLocation = self.center;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 3) {
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f; theta = 0.0f;
    }
    NSLog(@"tap count: %i", touch.tapCount);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void) updateTransformWithOffset: (CGPoint) translation
{
	// Create a blended transform representing translation, rotation, and scaling
	self.transform = CGAffineTransformMakeTranslation(translation.x + tx, translation.y + ty);
	self.transform = CGAffineTransformRotate(self.transform, theta);
	self.transform = CGAffineTransformScale(self.transform, scale, scale);
    
    NSLog(@"Xscale: %f YScale: %f Rotation: %f", self.xscale, self.yscale, self.rotation * (180 / M_PI));
}

- (void) setPosition: (CGPoint) position fromPosition: (CGPoint) previousPosition
{
	// Prepare undo-redo first. No completion blocks yet.
	[[self.undoManager prepareWithInvocationTarget:self] setPosition:previousPosition fromPosition:position];
	[self.viewController performSelector:@selector(checkUndoAndUpdate) withObject:nil afterDelay:0.2f];
	
	// Make the change
	[UIView animateWithDuration:0.1f animations:^{self.center = position;}];
}


- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
    CGPoint newcenter = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
    
    
	[self updateTransformWithOffset:translation];
    
    // Set new location
	self.center = newcenter;
	
	// Test for end state
	if (uigr.state == UIGestureRecognizerStateEnded)
	{
		[self setPosition:self.center fromPosition:previousLocation];
		[self.viewController performSelector:@selector(checkUndoAndUpdate)];
	}

}

- (void) handleRotation: (UIRotationGestureRecognizer *) uigr
{
	theta = uigr.rotation;
	[self updateTransformWithOffset:CGPointZero];
    
}

- (void) handlePinch: (UIPinchGestureRecognizer *) uigr
{
	scale = uigr.scale;
	[self updateTransformWithOffset:CGPointZero];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(id)initWithImage:(UIImage *)image
{
    // Initialize and set as touchable
    if (!(self = [super initWithImage:image])) return self;
    
    self.userInteractionEnabled = YES;
    
    // Reset geometry to identities
    self.transform = CGAffineTransformIdentity;
    tx = 0.0f; ty = 0.0f; scale = 1.0f; theta = 0.0f;
    
    // Add gesture recognizer suite
    UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    
    self.gestureRecognizers = [NSArray arrayWithObjects:rot, pan, pinch, nil];
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    
    return self;
}

@end
