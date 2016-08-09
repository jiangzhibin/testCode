//
//  GlobalCommon.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/9/19.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "GlobalCommon.h"



NSUInteger DeviceSystemMajorVersion() {
  static NSUInteger _deviceSystemMajorVersion = -1;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
  });
  return _deviceSystemMajorVersion;
}
