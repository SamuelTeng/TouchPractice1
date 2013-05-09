//
//  CustomImagePicker.m
//  TouchPractice
//
//  Created by Samuel Teng on 13/2/22.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import "CustomImagePicker.h"
#import "UIImageExtras.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "NetworkManager.h"
#import <CFNetwork/CFNetwork.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface CustomImagePicker (){
    ASINetworkQueue *pantsQueue;
    ASIHTTPRequest *pantsRequest;
    BOOL failed;
    AppDelegate *imageDelegate;
}

@end

@implementation CustomImagePicker

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

-(void)receiveDidStart
{
//    self.downloadAlert = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"downloading" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [self.downloadAlert show];
    
    
//    self.activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.activityIndicator.frame=CGRectMake(142, 211, 37, 37);
    //self.activityIndicator.center = CGPointMake(CGRectGetMidX(downloadAlert.bounds), CGRectGetMidY(downloadAlert.bounds));
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //[self.view addSubview:_activityIndicator];
    //[self.activityIndicator startAnimating];
//    [self.downloadAlert addSubview:self.activityIndicator];
    [[NetworkManager sharedInstance] didStartNetworkOperation];

    
    
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    //self.statusLabel.text = statusString;
}


-(void)receiveDidStopWithStatus:(NSString *)statusString
/*after download, we need to redraw the scroll view; therefore, I claim a method that is used to draw the scroll view, and call it when the app needs to */
{
    if (statusString == nil) {
        assert(self.filePath != nil);
        if ([_clothFTP.title isEqualToString:@"Cancel"]) {
            [_images addObject:[UIImage imageWithContentsOfFile:self.filePath]];
            [_thumbs addObject:[[UIImage imageWithContentsOfFile:self.filePath]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
            [self drawScrollView];
            statusString = @"download completed";
        }else if ([_pantsFTP.title isEqualToString:@"Cancel"]){
            [_pantsImages addObject:[UIImage imageWithContentsOfFile:self.filePath]];
            [_pantsThumbs addObject:[[UIImage imageWithContentsOfFile:self.filePath]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
            [self drawScrollView];
        }
        
    }
//    self.downloadAlert = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:statusString delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [self.downloadAlert dismissWithClickedButtonIndex:0 animated:YES];
    
//    self.activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.activityIndicator.frame=CGRectMake(142, 211, 37, 37);
    _clothFTP.title = @"Cloth";
    _pantsFTP.title = @"Pants";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //[self.activityIndicator stopAnimating];
//    [self.activityIndicator removeFromSuperview];
//    self.activityIndicator = nil;
//    self.downloadAlert = nil;
        int i = _images.count;
    int j = _thumbs.count;
    NSLog(@"the count of cloth array is %i and %i",i,j);
    [[NetworkManager sharedInstance] didStopNetworkOperation];

}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

-(BOOL)clothIsReceiving
{
    /*when both pans and cloth use the smae ftp transfer code, two,clothIsReceiving and pantsIsReceiving, can be combined to one, isReceiving*/
    return (self.networkStream != nil);
}
- (BOOL)pantsIsReceiving
{
    return ([pantsRequest inProgress]);
}

- (void)clothStartReceive
{
    BOOL                success;
    NSURL *             url;
    //NSURLRequest *      request;
    
    assert(self.networkStream == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // First get and check the URL.
    url = [[NetworkManager sharedInstance] smartURLForString:@"ftp://nssdcftp.gsfc.nasa.gov/photo_gallery/image/spacecraft/pioneer10-11.jpg"];
    
    success = (url != nil);
    
    if (! success) {
        
    }else{
        self.filePath = [[NetworkManager sharedInstance] pathForItemFileWithItemType:@"cloth"];
        assert(self.filePath != nil);
        
        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a CFFTPStream for the URL.
        
        self.networkStream = CFBridgingRelease(
                                               CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url)
                                               );
        assert(self.networkStream != nil);
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];

        
        [self receiveDidStart];
        
    }

}
//
//-(void)pantsStartReceive
//{
//    BOOL                success;
//    NSURL *             url;
//    NSURLRequest *      request;
//    
//    assert(self.connection == nil);         // don't tap receive twice in a row!
//    assert(self.fileStream == nil);         // ditto
//    assert(self.filePath == nil);           // ditto
//    
//    // First get and check the URL.
//    url = [[NetworkManager sharedInstance] smartURLForString:@"ftp://nssdcftp.gsfc.nasa.gov/photo_gallery/image/spacecraft/pioneer10-11.jpg"];
//    success = (url != nil);
//    
//    if (! success) {
//        
//    }else if (! [[NetworkManager sharedInstance] isImageURL:url]){
//        
//    }else{
//        self.filePath = [[NetworkManager sharedInstance] pathForItemFileWithItemType:fileName];
//        assert(self.filePath != nil);
//        
//        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
//        assert(self.fileStream != nil);
//        
//        [self.fileStream open];
//        
//        request = [NSURLRequest requestWithURL:url];
//        assert(request != nil);
//        
//        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
//        assert(self.connection != nil);
//        
//        [self receiveDidStart];
//        
//    }
//
//}

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
    
    NSURL *url = [NSURL URLWithString:@"http://allseeing-i.com/ASIHTTPRequest/tests/images/large-image.jpg"];
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

- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{
    if ([_clothFTP.title isEqualToString:@"Cancel"]) {
        if (self.networkStream != nil) {
            [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            self.networkStream.delegate = nil;
            [self.networkStream close];
            self.networkStream = nil;
        }
        if (self.fileStream != nil) {
            [self.fileStream close];
            self.fileStream = nil;
        }

    }else if ([_pantsFTP.title isEqualToString:@"Cancel"]){
        if (self.connection != nil) {
            [self.connection cancel];
            self.connection = nil;
        }
        if (self.fileStream != nil) {
            [self.fileStream close];
            self.fileStream = nil;
        }

    }
    
            [self receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSInteger       bytesRead;
            uint8_t         buffer[32768];
            
            [self updateStatus:@"Receiving"];
            
            // Pull some data off the network.
            
            bytesRead = [self.networkStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1) {
                [self stopReceiveWithStatus:@"Network read error"];
            } else if (bytesRead == 0) {
                [self stopReceiveWithStatus:nil];
            } else {
                NSInteger   bytesWritten;
                NSInteger   bytesWrittenSoFar;
                
                // Write to the file.
                
                bytesWrittenSoFar = 0;
                do {
                    bytesWritten = [self.fileStream write:&buffer[bytesWrittenSoFar] maxLength:(NSUInteger) (bytesRead - bytesWrittenSoFar)];
                    assert(bytesWritten != 0);
                    if (bytesWritten == -1) {
                        [self stopReceiveWithStatus:@"File write error"];
                        break;
                    } else {
                        bytesWrittenSoFar += bytesWritten;
                    }
                } while (bytesWrittenSoFar != bytesRead);
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopReceiveWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }

}
//
//- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
//{
//#pragma unused(theConnection)
//#pragma unused(response)
//    
//    assert(theConnection == self.connection);
//    assert(response != nil);
//    /*
//     [response suggestedFilename] is the name returned from downloaded file(the name could be the following:
//     A filename specified using the content disposition header;
//     The last path component of the URL; 
//     The host of the URL,respectively)
//     */
//    fileName = [response suggestedFilename];
//}
//
//- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
//{
//#pragma unused(theConnection)
//    NSUInteger      dataLength;
//    const uint8_t * dataBytes;
//    NSInteger       bytesWritten;
//    NSUInteger      bytesWrittenSoFar;
//    
//    assert(theConnection == self.connection);
//    
//    dataLength = [data length];
//    dataBytes  = [data bytes];
//    
//    bytesWrittenSoFar = 0;
//    do {
//        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
//        assert(bytesWritten != 0);
//        if (bytesWritten <= 0) {
//            [self stopReceiveWithStatus:@"File write error"];
//            break;
//        } else {
//            bytesWrittenSoFar += (NSUInteger) bytesWritten;
//        }
//    } while (bytesWrittenSoFar != dataLength);
//}
//
//- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
//{
//#pragma unused(theConnection)
//#pragma unused(error)
//    assert(theConnection == self.connection);
//    
//    [self stopReceiveWithStatus:@"Connection failed"];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
//{
//#pragma unused(theConnection)
//    assert(theConnection == self.connection);
//    
//    [self stopReceiveWithStatus:nil];
//
//}

-(id)init
{
    if ((self = [super init])) {
        _images = [[NSMutableArray alloc] init];
        _thumbs = [[NSMutableArray alloc] init];
        
        _pantsImages = [[NSMutableArray alloc] init];
        _pantsThumbs = [[NSMutableArray alloc] init];
        
//        int i = 1;
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/test%i.jpg",i]];
//        [_images addObject:[UIImage imageWithContentsOfFile:path]];
//        [_thumbs addObject:[UIImage imageWithContentsOfFile:path]];
                
//        for (int i = 1; i <= 8; i++) {
//            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/cloth%i.png",i]];
//            [_images addObject:[UIImage imageWithContentsOfFile:path]];
//            [_thumbs addObject:[[UIImage imageWithContentsOfFile:path]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
//        }
        
//        for (int j = 9; j <= 16; j++) {
//            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/pants%i.png",j]];
//            [_pantsImages addObject:[UIImage imageWithContentsOfFile:path]];
//            [_pantsThumbs addObject:[[UIImage imageWithContentsOfFile:path]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
//        }
        
//        if (self.filePath == nil) {
//            NSLog(@"download hasn't started yet!");
//        }else{
//            [_images addObject:[UIImage imageWithContentsOfFile:self.filePath]];
//            [_thumbs addObject:[[UIImage imageWithContentsOfFile:self.filePath]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];;
//        }


        
//        [_images addObject:[UIImage imageNamed:@"logo1.png"]];

//        
//        [_thumbs addObject:[[UIImage imageNamed:@"logo1.png"]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];

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
        [self stopReceiveWithStatus:@"cancelled"];
    }else{
        [self clothStartReceive];
        _clothFTP.title = @"Cancel";
    }
}

-(void)pantsFTPDownload:(id)sender
{
//    if (self.pantsIsReceiving) {
//        [self stopReceiveWithStatus:@"cancelled"];
//    }else{
//        [self pantsStartReceive];
//        _pantsFTP.title = @"Cancel";
//    }
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
    /*--------------------------------------------------------------------------------------*/
    /*add objects into array*/
    
//    for (int i = 1; i <= 8; i++) {
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/cloth%i.png",i]];
//        [_images addObject:[UIImage imageWithContentsOfFile:path]];
//        [_thumbs addObject:[[UIImage imageWithContentsOfFile:path]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
//    }
//    
//    for (int j = 9; j <= 16; j++) {
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/pants%i.png",j]];
//        [_pantsImages addObject:[UIImage imageWithContentsOfFile:path]];
//        [_pantsThumbs addObject:[[UIImage imageWithContentsOfFile:path]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
//    }
    
    /*------------------------------------------------------------------------------------*/



}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //create view
    [self drawScrollView];
    imageDelegate = [[UIApplication sharedApplication]delegate];
//    self.scrollView= [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
//    
//    self.scrollView.delegate = self;
//    
//    int row = 0;
//    int column = 0;
//    
//
//    for (int i = 0; i < _thumbs.count; ++i) {
//        UIImage *thumb = [_thumbs objectAtIndex:i];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(column*100+24, row*80+10, 64, 64);
//        [button setBackgroundImage:thumb forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = i;
//        [self.scrollView addSubview:button];
//        
//        if (column == 2) {
//            column = 0;
//            row++;
//        }else{
//            column++;
//        }
//    }
//
//    for (int i = 0; i < _pantsThumbs.count; ++i) {
//        UIImage *pantsThumb = [_pantsThumbs objectAtIndex:i];
//        UIButton *pantsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        pantsButton.frame = CGRectMake(column*100+24, row*80+10, 64, 64);
//        [pantsButton setBackgroundImage:pantsThumb forState:UIControlStateNormal];
//        [pantsButton addTarget:self action:@selector(pantsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        pantsButton.tag = i;
//        [self.scrollView addSubview:pantsButton];
//        
//        if (column == 2) {
//            column  = 0;
//            row++;
//        }else{
//            column ++;
//        }
//    }
//    
//    [self.scrollView setContentSize:CGSizeMake(320, (row+1)*80+10)];
//    
//    //self.view = self.scrollView;
//    [self.view addSubview:self.scrollView];
    
    //create cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    self.activityIndicator.hidden = YES;
    
    if (self.filePath == nil) {
        NSLog(@"download hasn't started yet!");
    }
//    else{
//        [_images addObject:[UIImage imageWithContentsOfFile:self.filePath]];
//        [_thumbs addObject:[[UIImage imageWithContentsOfFile:self.filePath]imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];;
//    }

    


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
    self.selectedImage = [_images objectAtIndex:button.tag];
    imageDelegate.selectedImage = [_images objectAtIndex:button.tag];
    //[self.navigationController popViewControllerAnimated:YES];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navi popViewControllerAnimated:YES];
    
}

-(void)pantsButtonClicked:(id)sender
{
    UIButton *pantsButton = (UIButton *)sender;
    self.pantsSelectedImage = [_pantsImages objectAtIndex:pantsButton.tag];
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

//-(void)dealloc
//{
//    self.images = nil;
//    self.thumbs = nil;
//    self.selectedImage = nil;
//    
//}

@end
