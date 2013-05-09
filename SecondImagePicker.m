//
//  SecondImagePicker.m
//  TouchPractice1
//
//  Created by Samuel Teng on 13/5/8.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "SecondImagePicker.h"
#import "UIImageExtras.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "NetworkManager.h"
#import <CFNetwork/CFNetwork.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@interface SecondImagePicker (){
    ASINetworkQueue *clothQueue;
    ASIHTTPRequest *clothRequest;
    ASINetworkQueue *pantsQueue;
    ASIHTTPRequest *pantsRequest;
    BOOL failed;
    AppDelegate *imageDelegate;
}


@end

@implementation SecondImagePicker

@synthesize scrollView;
@synthesize images = _images;
@synthesize thumbs = _thumbs;
@synthesize pantsImages = _pantsImages;
@synthesize pantsThumbs = _pantsThumbs;
@synthesize selectedImage = _selectedImage;
@synthesize pantsSelectedImage = _pantsSelectedImage;
@synthesize activityIndicator = _activityIndicator;
@synthesize clothFTP = _clothFTP;
@synthesize pantsFTP = _pantsFTP;
@synthesize clothIsReceiving,pantsIsReceiving,connection,filePath,networkStream,fileStream,downloadAlert,fileName;




#pragma mark * Core transfer code

// This is the code that actually does the networking.

-(BOOL)clothIsReceiving
{
    /*when both pans and cloth use the smae ftp transfer code, two,clothIsReceiving and pantsIsReceiving, can be combined to one, isReceiving*/
    return ([clothRequest inProgress]);
}
- (BOOL)pantsIsReceiving
{
    return ([pantsRequest inProgress]);
}

-(void)fetchClothImage
{
    if (! clothQueue) {
        clothQueue = [[ASINetworkQueue alloc] init];
    }
    failed = NO;
    [clothQueue reset];
    [clothQueue setRequestDidFinishSelector:@selector(clothFetchComplete:)];
    [clothQueue setRequestDidFailSelector:@selector(clothFetchFail:)];
    [clothQueue setDelegate:self];
    
    NSURL *url = [NSURL URLWithString:@"http://i.imgur.com/dSvsfQs.png?1"];
    clothRequest = [ASIHTTPRequest requestWithURL:url];
    NSString *nameOfFile = [url lastPathComponent];
    [clothRequest setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:nameOfFile]];
    [clothRequest setAllowResumeForFileDownloads:YES];
    [clothQueue addOperation:clothRequest];
    [clothQueue go];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)clothFetchComplete:(ASIHTTPRequest *)request
{
    [_images addObject:[UIImage imageWithContentsOfFile:[request downloadDestinationPath]]];
    [_thumbs addObject:[[UIImage imageWithContentsOfFile:[request downloadDestinationPath]]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
    [self drawScrollView];
     _clothFTP.title = @"Cloth";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}

-(void)clothFetchFail:(ASIHTTPRequest *)request
{
    if (! failed) {
        if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] !=
            ASIRequestCancelledErrorType) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Fail to download image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
        failed = YES;
    }
    _clothFTP.title = @"Pants";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)clothPauseDownload:(ASIHTTPRequest *)request
{
    [request clearDelegatesAndCancel];
    _clothFTP.title = @"Pants";
}

-(void)fetchPantsImage
{
    if (! pantsQueue) {
        pantsQueue = [[ASINetworkQueue alloc] init];
    }
    failed = NO;
    [pantsQueue reset];
    [pantsQueue setRequestDidFinishSelector:@selector(pantsFetchComplete:)];
    [pantsQueue setRequestDidFailSelector:@selector(pantsFetchFail:)];
    [pantsQueue setDelegate:self];
    
    NSURL *url = [NSURL URLWithString:@"http://pic.pimg.tw/jtlovejs/1312722063-070479c785699f50eb8d33e9a9e89f82.jpg"];
    pantsRequest = [ASIHTTPRequest requestWithURL:url];
    NSString *nameOfFile = [url lastPathComponent];
    [pantsRequest setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:nameOfFile]];
    [pantsRequest setAllowResumeForFileDownloads:YES];
    [pantsQueue addOperation:pantsRequest];
    [pantsQueue go];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}



-(void)pantsFetchComplete:(ASIHTTPRequest *)request
{
    [_pantsImages addObject:[UIImage imageWithContentsOfFile:[request downloadDestinationPath]]];
    [_pantsThumbs addObject:[[UIImage imageWithContentsOfFile:[request downloadDestinationPath]]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
    [self drawScrollView];
    _pantsFTP.title = @"Pants";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)pantsFetchFail:(ASIHTTPRequest *)request
{
    if (! failed) {
        if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] !=
            ASIRequestCancelledErrorType) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Fail to download image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
        failed = YES;
    }
    _pantsFTP.title = @"Pants";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

-(void)pantsPauseDownload:(ASIHTTPRequest *)request
{
    [request clearDelegatesAndCancel];
    _pantsFTP.title = @"Pants";
}

    


-(id)init
{
    if ((self = [super init])) {
        _images = [[NSMutableArray alloc] init];
        _thumbs = [[NSMutableArray alloc] init];
        
        _pantsImages = [[NSMutableArray alloc] init];
        _pantsThumbs = [[NSMutableArray alloc] init];
        

    }
    
    
    return self;
}

-(void)addImage:(UIImage *)image
{
    [_images addObject:image];
    [_thumbs addObject:[image imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
}

-(void)addPantsImage: (UIImage *)image
{
    [_pantsImages addObject:(UIImage *)image];
    [_pantsThumbs addObject:[image imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
}

-(void)clothFTPDownload:(id)sender
{
    if (self.clothIsReceiving) {
        [self clothPauseDownload:clothRequest];
    }else{
        [self fetchClothImage];
        _clothFTP.title = @"Cancel";
    }
}

-(void)pantsFTPDownload:(id)sender
{

    if (self.pantsIsReceiving) {
        NSLog(@"canceled");
        [self pantsPauseDownload:pantsRequest];
    }else{
        [self fetchPantsImage];
        _pantsFTP.title = @"Cancel";
    }
    
}

-(void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIImage *yahooImage = [UIImage imageNamed:@"yahoo.png"];
    UIButton *fowardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fowardButton setBackgroundImage:yahooImage forState:UIControlStateNormal];
    fowardButton.frame = CGRectMake(0, 0, yahooImage.size.width, yahooImage.size.height);
    [fowardButton addTarget:self action:@selector(foward:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *foward = [[UIBarButtonItem alloc] initWithCustomView:fowardButton];
    
    self.clothFTP = [[UIBarButtonItem alloc] initWithTitle:@"Cloth" style:UIBarButtonItemStyleBordered target:self action:@selector(clothFTPDownload:)];
    
    self.pantsFTP = [[UIBarButtonItem alloc] initWithTitle:@"Pants" style:UIBarButtonItemStyleBordered target:self action:@selector(pantsFTPDownload:)];
    
    NSArray *ftpDownloads = [[NSArray alloc] initWithObjects:foward,_clothFTP, _pantsFTP, nil];
    
    self.navigationItem.leftBarButtonItems = ftpDownloads;

    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //create view
    [self drawScrollView];
    imageDelegate = [[UIApplication sharedApplication]delegate];
        
    //create cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    self.activityIndicator.hidden = YES;
    
    if (self.filePath == nil) {
        NSLog(@"download hasn't started yet!");
    }
        
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

-(void)drawScrollView
{
    self.scrollView= [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    
    self.scrollView.delegate = self;
    
    int row = 0;
    int column = 0;
    
    
    for (int i = 0; i < _thumbs.count; ++i) {
        UIImage *thumb = [_thumbs objectAtIndex:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*100+24, row*80+10, 64, 64);
        [button setBackgroundImage:thumb forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.scrollView addSubview:button];
        
        if (column == 2) {
            column = 0;
            row++;
        }else{
            column++;
        }
    }
    
    for (int i = 0; i < _pantsThumbs.count; ++i) {
        UIImage *pantsThumb = [_pantsThumbs objectAtIndex:i];
        UIButton *pantsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pantsButton.frame = CGRectMake(column*100+24, row*80+10, 64, 64);
        [pantsButton setBackgroundImage:pantsThumb forState:UIControlStateNormal];
        [pantsButton addTarget:self action:@selector(pantsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        pantsButton.tag = i;
        [self.scrollView addSubview:pantsButton];
        
        if (column == 2) {
            column  = 0;
            row++;
        }else{
            column ++;
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(320, (row+1)*80+10)];
    
    //self.view = self.scrollView;
    [self.view addSubview:self.scrollView];
    
    
}


-(void)buttonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    //self.selectedImage = [_images objectAtIndex:button.tag];
    imageDelegate.selectedImage = [_images objectAtIndex:button.tag];
    //[self.navigationController popViewControllerAnimated:YES];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navi popViewControllerAnimated:YES];
    
}

-(void)pantsButtonClicked:(id)sender
{
    UIButton *pantsButton = (UIButton *)sender;
    //self.pantsSelectedImage = [_pantsImages objectAtIndex:pantsButton.tag];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.pantsSelectedImage = [_pantsImages objectAtIndex:pantsButton.tag];
    [delegate.navi popViewControllerAnimated:YES];
}

-(void)cancel:(id)sender
{
    self.selectedImage = nil;
    //[self.navigationController popViewControllerAnimated:YES];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navi popViewControllerAnimated:YES];
}

-(void)foward:(id)sender
{
    
    //NSDictionary *store = [[NSDictionary alloc] initWithObjectsAndKeys:@"Stroe Name",@"storeName",@"http://tw.bid.yahoo.com/",@"urlString", nil];
    WebViewController *webViewController = [[WebViewController alloc] init];
    //webViewController.urlDictionary = store;
    webViewController.pathString = @"http://tw.bid.yahoo.com/";
    webViewController.pageTitle = @"Stroe Name";
    //[webViewController setUrlDictionary:store];
    AppDelegate *web = [[UIApplication sharedApplication] delegate];
    UINavigationController *controller = [web navi];
    [controller pushViewController:webViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
