//
//  WebViewController.h
//  TouchPractice1
//
//  Created by Samuel Teng on 13/3/29.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)NSDictionary *urlDictionary;
@property (nonatomic,strong)NSString *pathString;
@property (nonatomic,strong)NSString *pageTitle;

@end
