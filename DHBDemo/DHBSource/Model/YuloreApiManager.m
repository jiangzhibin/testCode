//
//  YuloreApiManager.m
//  DianHuaBangSDK
//
//  Created by Zhang Heyin on 14-4-22.
//  Copyright (c) 2014年 com.yulore. All rights reserved.
//

#import "YuloreApiManager.h"
@interface YuloreApiManager ()


@end
@implementation YuloreApiManager
+ (instancetype)sharedYuloreApiManager {
  static YuloreApiManager *instance;
  

  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      instance = [YuloreApiManager new];
  });
  return instance;
}

@end
