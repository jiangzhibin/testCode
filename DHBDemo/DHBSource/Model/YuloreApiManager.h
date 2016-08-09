//
//  YuloreApiManager.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/8.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 允许执行下载操作的网络类型
typedef NS_ENUM(NSInteger,DownloadNetworkType) {
    DownloadNetworkTypeWifiOnly,    // 仅wifi网络
    DownloadNetworkTypeAllAllow,    // 所有网络
    DownloadNetworkTypeNotAllow     // 禁止联网
};


@interface YuloreApiManager : NSObject

/// 用户定位或选择的城市id
@property (nonatomic, copy) NSString *cityId;

/// 允许执行下载操作的网络类型(默认DownloadNetworkTypeWifiOnly)
@property (nonatomic, assign) DownloadNetworkType downloadNetworkType;

@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, copy) NSString *signature;

+ (instancetype)sharedYuloreApiManager;

+ (BOOL) registerApp:(NSString *)apikey
           signature:(NSString *)signature
     completionBlock:(void (^)(NSError *error) )completionBlock;

@end
