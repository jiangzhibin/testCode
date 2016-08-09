//
//  DHBDataFetcher.h
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBDataFetcher : NSObject
+ (instancetype)sharedInstance;
- (void)fullDataFetcherCompletionHandler:(void (^)( NSArray *fullPackageList, NSArray *deltaPackageList , NSError *error) )completionHandler;
- (void)dataFetcherCompletionHandler:(void (^)( NSArray *results, NSError *error) )completionHandler;
@end
