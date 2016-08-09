//
//  GlobalSettings.h
//  AppSales
//
//  Created by Ole Zorn on 23.07.11.
//  Copyright 2011 omz:software. All rights reserved.
//
typedef NS_ENUM(NSInteger, DHBMarkNumberType) {
  DHBMarkNumberTypeUnMark         =-1,//未能反查
  DHBMarkNumberTypeAdvertising        = 0,//广告推销
  DHBMarkNumberTypeHarassing          = 1,//骚扰电话
  DHBMarkNumberTypeSuspectedFraud     = 2,//疑似诈骗
  DHBMarkNumberTypeExpress            = 3,//快递送餐
  DHBMarkNumberTypeIntermediary       = 4,//房产中介
  DHBMarkNumberTypeRoomService        = 5,//外卖送餐
  DHBMarkNumberTypeInsuranceMarketing = 6,//保险推销
  DHBMarkNumberTypeUserDefine         = 7,//保险推销
  
};

typedef void(^DHBMarkViewActionHandler)(DHBMarkNumberType taggedType);
#define kERRORTYPETELENUMER @"mTelnum"
#define kERRORTYPEADDRESS   @"mAddress"
#define kERRORTYPEINFO      @"mInfo"
#define kERRORTYPEOTHER     @"mOther"
#define kERRORTYPEMNEW      @"mNew"
#define kERRORTYPE          @"errortype"
#define kSYSTEM             @"system"
#define kVERSION            @"version"
#define kSHOPID             @"shopid"
#define kCITY_ID            @"city_id"
#define kSEARCHCATEGORY     @"t"
#define kCAT_ID             @"cat_id"
#define kSTART              @"s"
#define kNUMBER             @"n"
#define kQUERY              @"q"
#define kUID                @"uid"
#define kMN                 @"mn"
#define kLAT                @"lat"
#define kLNG                @"lng"
#define kOLDER              @"o"
#define kUIP                @"uip"
#define kSID                @"sid"
#define kDIS_ID             @"dis_id"
#define kSIGNATURE          @"sig"





#define kHost @"apis-ios.dianhua.cn"
#define kDIANHUACNURL       @"https://apis-ios.dianhua.cn/"

#define kNOTICELOCATING  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ? @"『附近』需要定位功能，请在『设置』->『电话邦』->『位置』中启用定位，现在去设置？" : @"『附近』需要定位功能，请在『设置』->『隐私』->『定位服务』->『电话邦』开关中启用定位。"

//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS


#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif


// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) DLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)





typedef NS_ENUM(NSInteger, MainViewItemsType) {
  MainViewItemsTypeLocalService,
  MainViewItemsTypeCommonService,
  MainViewItemsTypeCategory ,
  MainViewItemsTypeNeaby
};
//
//typedef enum : NSUInteger {
//  DHBJSBridgeLoadNativeTypeCategory,
//  DHBJSBridgeLoadNativeTypeNearby,
//} DHBJSBridgeLoadNativeType;
//
//
//

