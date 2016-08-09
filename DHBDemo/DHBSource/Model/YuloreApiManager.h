//
//  YuloreApiManager.h
//  DianHuaBangSDK
//
//  Created by Zhang Heyin on 14-4-22.
//  Copyright (c) 2014年 com.yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YuloreApiManager : NSObject
+ (instancetype)sharedYuloreApiManager;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *signature;
@end
