//
//  WebViewController.m
//  TouchPractice1
//
//  Created by Samuel Teng on 13/3/29.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController ()

@end

@implementation WebViewController{
    UIActivityIndicatorView *spinner;
}
@synthesize webView,urlDictionary,pageTitle,pathString;

//-(void)setPageData:(NSDictionary *)url_Dictionary
//{
//    urlDictionary = url_Dictionary;
//    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    self.webView.delegate = self;
//    [self.view addSubview:self.webView];
//    self.title = [urlDictionary objectForKey:@"storeName"];
//    
//    NSString *url = [urlDictionary objectForKey:@"urlString"];
//    NSURL *storePage = [[NSURL alloc] initWithString:url];
//    NSURLRequest *requestURL = [[NSURLRequest alloc] initWithURL:storePage];
//    [self.webView loadRequest:requestURL];
//}

-(void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = pageTitle;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
    [self.view addSubview:webView];
    
    NSString *url = pathString;
    NSURL *pathUrl = [[NSURL alloc] initWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:pathUrl];
    [self.webView loadRequest:request];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.frame = self.view.bounds;
    self.webView.scalesPageToFit = YES;
    spinner.frame = self.view.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [spinner stopAnimating];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    spinner.color=[UIColor blackColor];
    [self.view addSubview:spinner];
    [spinner startAnimating];
}


@end
