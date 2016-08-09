//
//  Commondef.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/5.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#ifndef Commondef_h
#define Commondef_h
#ifdef __OBJC__
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#define kDIANHUACNURL            @"https://apis-ios.dianhua.cn/"
//#define DIANHUABANG_APIKEY @"6WWpOS2NreERRbkJpYVVJd1lVZFZaMkw"
//#define DIANHUABANG_SIG @"yv3%D_d&-hq3F8JmDr!?cf#dk3pvs2#D_d&-vaSc7szVs!jcCs5$NvY2ul__o)3s!__Ns$__g4*d__cne@__c#bst9sk-c$xA__5#jclsOc9^bv2__7cJ&h__ld4=U3Kij*sD5&_ds2{hX13e2@s9C#s3#zF!v%ba^2Dc"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#pragma mark -
#pragma mark - UIScreen
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)


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

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UICOLOR_TINT_DHB UIColorFromRGB(0xff4a00)
#define UICOLOR_NAVIGATION_BAR UIColorFromRGB(0xDE5336)



#define kDIANHUACNURL            @"https://apis-ios.dianhua.cn/"

#endif /* Commondef_h */
#endif
