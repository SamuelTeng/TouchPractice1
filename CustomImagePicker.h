//
//  CustomImagePicker.h
//  TouchPractice
//
//  Created by Samuel Teng on 13/2/22.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomImagePicker : UIViewController<UIScrollViewDelegate,NSURLConnectionDelegate,NSStreamDelegate>

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)NSMutableArray *images;
@property (nonatomic,strong)NSMutableArray *thumbs;
@property (nonatomic,strong)NSMutableArray *pantsImages;
@property (nonatomic,strong)NSMutableArray *pantsThumbs;
@property (nonatomic,strong)UIImage *selectedImage;
@property (nonatomic,strong)UIImage *pantsSelectedImage;

@property (nonatomic, strong, readwrite)  UIActivityIndicatorView *   activityIndicator;
// Properties that don't need to be seen by the outside world.

@property (nonatomic,strong) UIBarButtonItem *clothFTP;
@property (nonatomic,strong) UIBarButtonItem *pantsFTP;
@property (nonatomic, assign, readonly ) BOOL              clothIsReceiving;
@property (nonatomic,assign,readonly) BOOL pantsIsReceiving;
@property (nonatomic, strong, readwrite) NSURLConnection * connection;
@property (nonatomic, copy,   readwrite) NSString *        filePath;
@property (nonatomic,strong,readwrite) NSInputStream *networkStream;
@property (nonatomic, strong, readwrite) NSOutputStream *  fileStream;
@property (nonatomic,strong) NSString *fileName;

@property (nonatomic,strong) UIAlertView *downloadAlert;

-(void)addImage: (UIImage *)image;
-(void)addPantsImage: (UIImage *)image;
@end
