//
//  MainViewController.h
//  TouchPractice1
//
//  Created by Samuel Teng on 13/2/25.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragView.h"
#import "ExpandableButtonBar.h"
#import "ExpandableClearBar.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@class CustomImagePicker,SecondImagePicker;
@interface MainViewController:UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,ExpandableButtonBarDelegate,UIAlertViewDelegate,ExpandableClearBarDelegate>{
    
    UIPopoverController *popoverController;
    
    //    UIImage *ima ;
    DragView *dv;
    DragView *pantsDV;
    
    ExpandableButtonBar *_bar;
    ExpandableClearBar *_claerBar;
    
    NSString *path;
    

    
   
    
}

@property (nonatomic,strong) UIImageView *ima;
@property (nonatomic,strong) CustomImagePicker *imagePicker;
@property (nonatomic,strong) SecondImagePicker *secondPicker;
@property (nonatomic,strong) UIImageView *background;

@property (nonatomic,strong) UIButton *undoButton;

@property (nonatomic,strong) UIImageView *clothImage;
@property (nonatomic,strong) UIImageView *pantsImage;

/*Expandable Button Bar*/
@property (nonatomic,strong)ExpandableButtonBar *bar;
-(void)onNext;
-(void)onAlert;
-(void)onModal;

/*Expandable Clear Bar*/
@property (nonatomic,strong)ExpandableClearBar *clearBar;
-(void)clearCloth;
-(void)clearPant;
-(void)clearAll;



@end

