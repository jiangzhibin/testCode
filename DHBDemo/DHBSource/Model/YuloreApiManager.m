//
//  YuloreApiManager.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/8.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
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
