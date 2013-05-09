//
//  MainViewController.m
//  TouchPractice1
//
//  Created by Samuel Teng on 13/2/25.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "DragView.h"
#import "CustomImagePicker.h"
#import "UIImageExtras.h"
#import "SecondImagePicker.h"

@interface MainViewController ()

@end

@implementation MainViewController{
    AppDelegate *imageDelegate;
}

@synthesize ima;
@synthesize imagePicker = _imagePicker;
@synthesize secondPicker = _secondPicker;
@synthesize background;
@synthesize bar = _bar;
@synthesize clearBar = _claerBar;
@synthesize clothImage,pantsImage;


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenSize.size.width;
    CGFloat screenHeight = screenSize.size.height;
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *scaleImage = [image imageByScalingAndCroppingForSize:CGSizeMake(screenWidth, screenHeight-44)];
    //[UIImage imageWithCGImage:[image CGImage] scale:(image.scale*1.85) orientation:(image.imageOrientation)];
    background = [[UIImageView alloc] initWithImage:scaleImage];
    background.center = self.view.center;
    [self.view addSubview:background];
    [[background superview] sendSubviewToBack:background];
    /*keep bar button always above images*/
    [background setTag:101];
    //[self.view insertSubview:background belowSubview:_bar];
//    DragView *dv = [[DragView alloc] initWithImage:image];
//    dv.center = self.view.center;
//    
//    [self.view addSubview:dv];
    
    if (IS_IPHONE) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }else{
        // iPad. dismiss popover controller
        
        /* If you dismiss the popover programmatically, you should perform any cleanup actions immediately after calling the dismissPopoverAnimated: method.*/
        
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

// Popover was dismissed
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)apopoverController
{
    /*You can use this method to incorporate any changes from the popover’s content view controller back into your application. If you do not plan to use the object in the popoverController parameter again, it is safe to release it from this method.*/
    
    popoverController = nil;
}

-(void)pickImage:(id)sender
{
    // Create an initialize the picker, keep retain count at +1
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    {
        ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        ipc.delegate = self;
    }
    
    if (IS_IPHONE) {
        /*the "completion" is allowed to be an empty block but not null*/
        [self presentViewController:ipc animated:YES completion:^{
            
        }];
        //[self presentModalViewController:ipc animated:YES];
    }else{
        // Create a retained popover
        popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
        popoverController.delegate = self;
        
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

//-(void)ftpDownload:(id)sender
//{
//    NSLog(@"connect to ftp server");
//    //[self.navigationController pushViewController:_imagePicker animated:YES];
////    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
////    UINavigationController *controloler = [delegate navi];
////    [controloler pushViewController:_imagePicker animated:YES];
//    
//}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*touch to show*/
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
     dv = [[DragView alloc] initWithImage:imageDelegate.selectedImage];
    //dv = [[DragView alloc] initWithImage:_imagePicker.selectedImage];
    pantsDV = [[DragView alloc] initWithImage:imageDelegate.pantsSelectedImage];
    //ima = dv;
    //dv.frame = CGRectMake(20, 65, 280, 192);
    dv.center = point;
    pantsDV.center = point;
    [dv setTag:102];
    [pantsDV setTag:103];
    
    
    /*due to the reason that dv is still connected to the CustomPicker;therefore, when user make another pick, the previous one will change to new pick. the solution is to make each single pick as an individual one by claiming it nil after addSubview*/

    if ([self.view viewWithTag:102] == nil && [self.view viewWithTag:101] != nil) {
       
            [self.view addSubview:dv];
            dv = nil;
        
    }else if ([self.view viewWithTag:103] == nil && [self.view viewWithTag:101] != nil){
        [self.view addSubview:pantsDV];
        pantsDV = nil;
        
    }else if ([self.view viewWithTag:101] == nil ) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"請先選擇全身照,按下ok進行挑選" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [av show];
        NSLog(@"alert view");
        
    }
//    else if ([self.view viewWithTag:102] != nil){
//        [self.view addSubview:pantsDV];
//        pantsDV = nil;
//    }else if ([self.view viewWithTag:103] != nil){
//        [self.view addSubview:dv];
//        dv = nil;
//    }
    
    
    
    
//    if (dv == nil) {
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:self.view];
//        dv = [[DragView alloc] initWithImage:_imagePicker.selectedImage];
//        ima = dv;
//        //dv.frame = CGRectMake(20, 65, 280, 192);
//        dv.center = point;
//        
//        
//        [self.view addSubview:dv];
//    }
}
/*---------------------------------------------------------------------------------------------------*/
/*Expandable Bar Button method:page 5*/
-(void)onNext
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *controloler = [delegate navi];
    [controloler pushViewController:_imagePicker animated:YES];
}

-(void)onAlert
{
    NSLog(@"change the method name and add second page");
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *controller = [delegate navi];
    [controller pushViewController:_secondPicker animated:YES];
}

-(void)onModal
{
    NSLog(@"change the method name and add third page");
}

/*---------------------------------------------------------------------------------------------------*/
/*Expandable Bar clear method*/

-(void)clearCloth
{
    UIView *removeClothView = [self.view viewWithTag:102];
    [removeClothView removeFromSuperview];
}
-(void)clearPant
{
    UIView *removePantView = [self.view viewWithTag:103];
    [removePantView removeFromSuperview];
}
-(void)clearAll
{
    if ([self.view viewWithTag:101] != nil && [self.view viewWithTag:102] != nil && [self.view viewWithTag:103] != nil) {
        [[self.view viewWithTag:101] removeFromSuperview];
        [[self.view viewWithTag:102] removeFromSuperview];
        [[self.view viewWithTag:103] removeFromSuperview];
    }else if ([self.view viewWithTag:101] != nil && [self.view viewWithTag:102] == nil && [self.view viewWithTag:103] == nil){
        [[self.view viewWithTag:101] removeFromSuperview];
    }
//    UIView *removeBackground = [self.view viewWithTag:101];
//    [removeBackground removeFromSuperview];
//    UIView *removeClothView = [self.view viewWithTag:102];
//    [removeClothView removeFromSuperview];
//    UIView *removePantView = [self.view viewWithTag:103];
//    [removePantView removeFromSuperview];

    
}

/* ---------------------------------------------------------
 * Delegate methods of ExpandableButtonBarDelegate
 * -------------------------------------------------------*/
- (void) expandingBarDidAppear:(ExpandableButtonBar*)bar
{
    NSLog(@"did appear");
}

- (void) expandingBarWillAppear:(ExpandableButtonBar*)bar
{
    NSLog(@"will appear");
}

- (void) expandingBarDidDisappear:(ExpandableButtonBar*)bar
{
    NSLog(@"did disappear");
}

- (void) expandingBarWillDisappear:(ExpandableButtonBar*)bar
{
    NSLog(@"will disappear");
}

/* ---------------------------------------------------------
 * Delegate methods of ExpandableClearBarDelegate
 * -------------------------------------------------------*/

- (void) expandingClearBarWillAppear:(ExpandableClearBar*)clearBar
{
    NSLog(@"did appear");
}
- (void) expandingClearBarDidAppear:(ExpandableClearBar*)clearBar
{
    NSLog(@"will appear");
}
- (void) expandingClearBarWillDisappear:(ExpandableClearBar*)clearBar
{
    NSLog(@"did disappear");
}
- (void) expandingClearBarDidDisappear:(ExpandableClearBar*)clearBar
{
    NSLog(@"will disappear");
}

/* ---------------------------------------------------------
 * Delegate methods of UIAlertView
 * -------------------------------------------------------*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"click cancel button");
            break;
            
        case 1:
            NSLog(@"click ok button");
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        {
            ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            ipc.delegate = self;
        }
            
            if (IS_IPHONE) {
                /*the "completion" is allowed to be an empty block but not null*/
                [self presentViewController:ipc animated:YES completion:^{
                    
                }];
                //[self presentModalViewController:ipc animated:YES];
            }else{
                // Create a retained popover
                popoverController = [[UIPopoverController alloc] initWithContentViewController:ipc];
                popoverController.delegate = self;
                
                [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }

            break;
            

    }
}

/* ---------------------------------------------------------
 * save photo function
 * -------------------------------------------------------*/
//-(void)Saved:(id)sender
//{
//    CGRect rect = self.view.frame;
//    clothImage.image = dv.image;
//    pantsImage.image = pantsDV.image;
//    UIGraphicsBeginImageContext(self.view.bounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [background.image drawInRect:rect];
//    CGContextSaveGState(context);
//    CGContextRestoreGState(context);
//    
//
//    
//    if ([self.view viewWithTag:101] != nil && [self.view viewWithTag:102] != nil && [self.view viewWithTag:103] != nil) {
//        [_imagePicker.selectedImage drawInRect:clothImage.frame blendMode:kCGBlendModeNormal alpha:1.0f];
//        CGContextSaveGState(context);
//        CGContextRestoreGState(context);
//        
//        [_imagePicker.pantsSelectedImage   drawInRect:pantsImage.frame blendMode:kCGBlendModeNormal alpha:1.0f];
//        CGContextSaveGState(context);
//        CGContextRestoreGState(context);
//        
//        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        NSLog(@"save all items");
//    }else if ([self.view viewWithTag:101] != nil && [self.view viewWithTag:102] != nil){
//        [dv.image drawInRect:clothImage.frame blendMode:kCGBlendModeNormal alpha:1.0f];
//        CGContextSaveGState(context);
//        CGContextRestoreGState(context);
//        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        NSLog(@"save cloth and background");
//
//    }else if ([self.view viewWithTag:101] != nil && [self.view viewWithTag:103] != nil){
//        [pantsDV.image drawInRect:pantsImage.frame blendMode:kCGBlendModeNormal alpha:1.0f];
//        CGContextSaveGState(context);
//        CGContextRestoreGState(context);
//        
//        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        NSLog(@"save pants and background");
//
//    }
//}

// 儲存錯誤處理
//- (void) image:(UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo {
//    // 顯示錯誤訊息
//}

/*---------------------------------------------------------------------------------------------------*/
-(void)loadView
{
    [super loadView];
    self.view.backgroundColor=[UIColor whiteColor];
    
    _imagePicker = [[CustomImagePicker alloc] init];
    
    _secondPicker = [[SecondImagePicker alloc] init];
    
    //    UINavigationController *pickViewController = [[UINavigationController alloc] initWithRootViewController:_imagePicker];
    //    pickViewController.title = @"Choose Custom Image";
    
    
//        [_imagePicker addImage:[UIImage imageNamed:@"cloth1.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth2.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth3.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth4.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth5.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth6.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth7.png"]];
//    	[_imagePicker addImage:[UIImage imageNamed:@"cloth8.png"]];
//        [_imagePicker addPantsImage:[UIImage imageNamed:@"pants9.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants10.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants11.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants12.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants13.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants14.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants15.png"]];
//    	[_imagePicker addPantsImage:[UIImage imageNamed:@"pants16.png"]];
//    int i = 1;
//    path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/test%i.jpg",i]];
//    
//    [_imagePicker addImage:[UIImage imageWithContentsOfFile:path]];
    
/*-----------------------Expandable Bar Button method:page 5-----------------------------------------*/
    
    /* ---------------------------------------------------------
     * Create images that are used for the main button
     * -------------------------------------------------------*/
    UIImage *image = [UIImage imageNamed:@"red_plus_up.png"];
    UIImage *selectedImage = [UIImage imageNamed:@"red_plus_down.png"];
    UIImage *toggledImage = [UIImage imageNamed:@"red_x_up.png"];
    UIImage *toggledSelectedImage = [UIImage imageNamed:@"red_x_down.png"];
    
    /* ---------------------------------------------------------
     * Create the center for the main button and origin of animations
     * -------------------------------------------------------*/
    CGPoint center = CGPointMake(30.0f, 370.0f);
    
    /* ---------------------------------------------------------
     * Setup buttons
     * Note: I am setting the frame to the size of my images
     * -------------------------------------------------------*/
    CGRect buttonFrame = CGRectMake(0, 0, 32.0f, 32.0f);
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b1 setFrame:buttonFrame];
    [b1 setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [b1 addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b2 setImage:[UIImage imageNamed:@"lightbulb.png"] forState:UIControlStateNormal];
    [b2 setFrame:buttonFrame];
    [b2 addTarget:self action:@selector(onAlert) forControlEvents:UIControlEventTouchUpInside];
    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [b3 setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    [b3 setFrame:buttonFrame];
    [b3 addTarget:self action:@selector(onModal) forControlEvents:UIControlEventTouchUpInside];
    NSArray *buttons = [NSArray arrayWithObjects:b1, b2, b3, nil];
    
    /* ---------------------------------------------------------
     * Init method, passing everything the bar needs to work
     * -------------------------------------------------------*/
    
    ExpandableButtonBar *bar = [[ExpandableButtonBar alloc] initWithImage:image selectedImage:selectedImage toggledImage:toggledImage toggledSelectedImage:toggledSelectedImage buttons:buttons center:center];

    
    /* ---------------------------------------------------------
     * Settings
     * -------------------------------------------------------*/
    [bar setDelegate:self];
    [bar setSpin:YES];
    
    
    
    /* ---------------------------------------------------------
     * Set our property and add it to the view
     * -------------------------------------------------------*/
    [self setBar:bar];
    [self.view addSubview:bar];
    
    
/*---------------------------------------------------------------------------------------------------*/
    /*-------------------------------Expandable Clear Bar----------------------------------------*/
    
    /* ---------------------------------------------------------
     * Create images that are used for the main button
     * -------------------------------------------------------*/
    UIImage *clearImage = [UIImage imageNamed:@"red_plus_up.png"];
    UIImage *clearSelectedImage = [UIImage imageNamed:@"red_plus_down.png"];
    UIImage *clearToggledImage = [UIImage imageNamed:@"red_x_up.png"];
    UIImage *clearToggledSelectedImage = [UIImage imageNamed:@"red_x_down.png"];
    
    /* ---------------------------------------------------------
     * Create the center for the main button and origin of animations
     * -------------------------------------------------------*/
    CGPoint clearCenter = CGPointMake(300.0f, 370.0f);
    
    /* ---------------------------------------------------------
     * Setup buttons
     * Note: I am setting the frame to the size of my images
     * -------------------------------------------------------*/
    CGRect clearFrame = CGRectMake(0, 0, 32.0f, 32.0f);
    UIButton *c1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [c1 setFrame:clearFrame];
    [c1 setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [c1 addTarget:self action:@selector(clearCloth) forControlEvents:UIControlEventTouchUpInside];
    UIButton *c2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [c2 setImage:[UIImage imageNamed:@"lightbulb.png"] forState:UIControlStateNormal];
    [c2 setFrame:clearFrame];
    [c2 addTarget:self action:@selector(clearPant) forControlEvents:UIControlEventTouchUpInside];
    UIButton *c3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [c3 setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    [c3 setFrame:clearFrame];
    [c3 addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
    NSArray *clearButtons = [NSArray arrayWithObjects:c1, c2, c3, nil];
    
    /* ---------------------------------------------------------
     * Init method, passing everything the bar needs to work
     * -------------------------------------------------------*/
    
    ExpandableClearBar *clearBar = [[ExpandableClearBar alloc] initWithImage:clearImage selectedImage:clearSelectedImage toggledImage:clearToggledImage toggledSelectedImage:clearToggledSelectedImage buttons:clearButtons center:clearCenter];
    
    
    /* ---------------------------------------------------------
     * Settings
     * -------------------------------------------------------*/
    [clearBar setClearDelegate:self];
    [clearBar setSpin:YES];
    
    
    
    /* ---------------------------------------------------------
     * Set our property and add it to the view
     * -------------------------------------------------------*/
    [self setClearBar:clearBar];
    [self.view addSubview:clearBar];

/*---------------------------------------------------------------------------------------------------*/
          
    
    //[[bar superview] bringSubviewToFront:bar];
    //[self.view insertSubview:bar aboveSubview:background];
    
    //self.ima.image = self.imagePicker.selectedImage;
    
    
    
    //    ima = [UIImage imageNamed:@"MagentaSquare.png"];
    //    UIImageView *view = [[UIImageView alloc] init];
    //    view.image = ima;
    //    view.frame = CGRectMake(100, 100, 90, 90);
    //    [self.view addSubview:view];
    
    
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    imageDelegate = [[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    UIBarButtonItem *addButton = BARBUTTON(@"Add Image", @selector(pickImage:));
    
   // UIBarButtonItem *saved = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(Saved:)];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:addButton, nil];
    
    self.navigationItem.rightBarButtonItems = buttons;

    //self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add Image", @selector(pickImage:));
    
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Picker" style:UIBarButtonSystemItemRefresh target:self action:@selector(ftpDownload:)];
    
    
 

    
    
//    ima = [[UIImageView alloc] initWithFrame:CGRectMake(20, 65, 280, 192)];
//    [self.view addSubview:ima];
    
    /*since DargView inherits from UIImageView, same as ima; therefore, we can assign DragView dv to ima to replace it*/
    
//    dv = [[DragView alloc] initWithImage:_imagePicker.selectedImage];
//    ima = dv;
//    dv.frame = CGRectMake(20, 65, 280, 192);
//    //dv.center = self.view.center;
//    
//    [self.view addSubview:dv];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dv.image = _imagePicker.selectedImage;
}

-(void)viewDidAppear:(BOOL)animated
{
    /*shake to clear*/
    
    [super viewDidAppear:animated];
    //[self becomeFirstResponder];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    /*shake to clear*/
    
    [super viewDidDisappear:animated];
    //[self resignFirstResponder];
}

/*not practical*/

//-(BOOL)canBecomeFirstResponder
//{
//    /*shake to clear*/
//    
//    return YES;
//}

//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    /*shake to clear the last subView*/
//    
//    NSLog(@"shake");
//    if (motion == UIEventSubtypeMotionShake) {
//        /*method that used to call the last subView*/
//        UIView *child = self.view.subviews.lastObject;
//        [child removeFromSuperview];
//        //[[self.view.subviews objectAtIndex:0]removeFromSuperview];
//        
////        [dv removeFromSuperview];
////        dv = nil;
//    }
//    
////    UIView *removeView;
////    while ((removeView = [self.view viewWithTag:102]) != nil) {
////        [removeView removeFromSuperview];
////    }
//
////    if (dv != nil && event.type == UIEventSubtypeMotionShake) {
////        [dv removeFromSuperview];
////        dv = nil;
////    }
//}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
