//
//  YuloreApiManager.h
//  DHBDemo
//
//  Created by Zhang Heyin on 15/2/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//
//  Modified by 蒋兵兵 on 16/08/11
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DHBSDKUpdateItem.h"
#import "DHBSDKResolveItemNew.h"

/// 允许执行下载操作的网络类型
typedef NS_ENUM(NSInteger,DHBSDKDownloadNetworkType) {
    DHBSDKDownloadNetworkTypeWifiOnly,      // 仅wifi网络
    DHBSDKDownloadNetworkTypeAllAllow,      // 所有网络
    DHBSDKDownloadNetworkTypeNotAllow       // 禁止联网
};

/// 下载的数据类型
typedef NS_ENUM(NSInteger,DHBSDKDownloadDataType) {
    DHBSDKDownloadDataTypeDelta,            // 全量包
    DHBSDKDownloadDataTypeFull,             // 增量包
};


@interface YuloreApiManager : NSObject


@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, copy) NSString *signature;

/// 用户所在城市id,用户修改城市后，需通过[YuloreApiManager shareManager].cityId 重新设置
@property (nonatomic, copy) NSString *cityId;

/// 电话邦host https://apis-ios.dianhua.cn/
@property (nonatomic, copy) NSString *host;

/// 用户定位信息（可选）
@property (nonatomic, assign) CLLocationCoordinate2D  coordinate;

/// 允许执行下载操作的网络类型(默认DHBSDKDownloadNetworkTypeWifiOnly)
@property (nonatomic, assign) DHBSDKDownloadNetworkType downloadNetworkType;

+ (instancetype)shareManager;

/**
 *  初始化所需ApiKey以及密码
 *
 *  @param apikey    所需apikey
 *  @param signature 所需signature
 *  @param host      电话邦host https://apis-ios.dianhua.cn/
 *  @param cityId      用户所在城市id,默认传@"0",待用户设置城市后，需通过[YuloreApiManager shareManager].cityId 重新设置
 *
 *  @return 是否设置成功
 */
+ (BOOL) registerApp:(NSString *)apikey
           signature:(NSString *)signature
                host:(NSString *)host
              cityId:(NSString *)cityId
     completionBlock:(void (^)(NSError *error) )completionBlock;

/**
 注册状态
 
 @return YES:当前已经注册  NO:尚未注册
 */
+ (BOOL)registered;


/**
 查询号码信息

 @param teleNumber        号码
 @param completionHandler 查询结果回调
 */
+ (void)searchTeleNumber:(NSString *)teleNumber
           completionHandler:(void (^)( DHBSDKResolveItemNew *resolveItem, NSError *error) )completionHandler;

/**
 在线标记号码
 
 @param aNumber             电话号码
 @param flagInfomation      被标记的信息
 @param completeBlock       标记完成的回调
 */
+ (void)markTeleNumberOnlineWithNumber:(NSString *)aNumber
                        flagInfomation:(NSString *)flagInfomation
                     completionHandler:(void (^)( BOOL successed, NSError *error))completeBlock;

/**
 数据信息获取
 如 更新包下载地址及md5等，详情见DHBSDKUpdateItem.h
 @param completionHandler 回调
 */
+ (void)dataInfoFetcherCompletionHandler:(void(^)(DHBSDKUpdateItem *updateItem, NSError *error))completionHandler;


/**
 下载 全量/增量包

 @param updateItem        下载所需的信息model
 @param dataType          下载的数据类型
 @param progressBlock     进度回调
 @param completionHandler 下载结束回调，error == nil，则下载失败；error == nil,下载成功
 */
+ (void)downloadDataWithUpdateItem:(DHBSDKUpdateItem *)updateItem
                          dataType:(DHBSDKDownloadDataType)dataType
                     progressBlock:(void(^)(double progress))progressBlock
                 completionHandler:(void(^)(NSError *error))completionHandler;

@end