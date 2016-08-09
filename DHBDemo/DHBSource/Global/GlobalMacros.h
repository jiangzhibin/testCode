//
//  GlobalMacros.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/9/19.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#ifndef SuperYellowPageSDK_GlobalMacros_h
#define SuperYellowPageSDK_GlobalMacros_h


#pragma mark -
#pragma mark - UIScreen
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#pragma mark -
#pragma mark - 16 Color
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



#pragma mark -
#pragma mark - SINGLETON_GCD
#ifndef SINGLETON_GCD
#define SINGLETON_GCD(classname)                       \
  \
  + (instancetype)shared##classname {                     \
  static dispatch_once_t pred;                         \
  __strong static classname * shared##classname = nil; \
  dispatch_once( &pred, ^{                             \
  shared##classname = [[self alloc] init]; });       \
  return shared##classname;                            \
  }
#endif

#define UICOLOR_TINT_DHB UIColorFromRGB(0xff4a00)
#define UICOLOR_NAVIGATION_BAR UIColorFromRGB(0xDE5336)


#endif
