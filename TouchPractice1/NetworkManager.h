//
//  NetworkManager.h
//  TouchPractice1
//
//  Created by Samuel Teng on 13/4/8.
//  Copyright (c) 2013年 Samuel Teng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedInstance;

- (NSURL *)smartURLForString:(NSString *)str;
- (BOOL)isImageURL:(NSURL *)url;

- (NSString *)pathForTestImage:(NSUInteger)imageNumber;
- (NSString *)pathForItemFileWithItemType:(NSString *)itemType;

@property (nonatomic, assign, readonly ) NSUInteger     networkOperationCount;  // observable

- (void)didStartNetworkOperation;
- (void)didStopNetworkOperation;

@end
