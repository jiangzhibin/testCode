//
//  StartLoadingService.h
//  yellopage
//
//  Created by Zhang Heyin on 14-3-28.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class StartLoadingService;
@protocol StartLoadingServiceDelegate <NSObject>

- (void)updateStartLoadingServiceDelegateAction;

@end
@interface StartLoadingService : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) NSString *trackViewUrl;


+ (void)updateLastVersion;
+ (BOOL)fetcherLastVersion;
+ (void) updateCurrentCity;
+ (void) copyInitDataCompletionBlock:(void (^)(NSError *error) )completionBlock;

+ (void) cacheServiceIconImageFromInternet2:(NSArray *)serviceArray
                                nearbyArray:(NSArray *)nearByArray
                          completionHandler:(void (^)(NSError *error))completionHandler;
//+ (void) startLocation;
@end
