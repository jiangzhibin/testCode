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

/// 允许执行下载操作的网络类型
typedef NS_ENUM(NSInteger,DownloadNetworkType) {
    DownloadNetworkTypeWifiOnly,    // 仅wifi网络
    DownloadNetworkTypeAllAllow,    // 所有网络
    DownloadNetworkTypeNotAllow     // 禁止联网
};


@interface YuloreApiManager : NSObject


@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, copy) NSString *signature;

/// 用户定位或选择的城市id （默认为@"0")
@property (nonatomic, copy) NSString *cityId;

/// 用户定位信息（可选）
@property (nonatomic, assign) CLLocationCoordinate2D  coordinate;

/// 允许执行下载操作的网络类型(默认DownloadNetworkTypeWifiOnly)
@property (nonatomic, assign) DownloadNetworkType downloadNetworkType;

+ (instancetype)sharedYuloreApiManager;

/**
 *  初始化所需ApiKey以及密码
 *
 *  @param apikey    所需apikey
 *  @param signature 所需signature
 *
 *  @return 是否设置成功
 */
+ (BOOL) registerApp:(NSString *)apikey
           signature:(NSString *)signature
     completionBlock:(void (^)(NSError *error) )completionBlock;

+ (BOOL)registered;
@end
