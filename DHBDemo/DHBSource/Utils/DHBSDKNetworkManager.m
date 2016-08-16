//
//  NetworkManager.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/16.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKNetworkManager.h"
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"

NSString *const kDHBSDKNotifReachabilityStatusChanged = @"kDHBSDKNotifReachabilityStatusChanged";

@implementation DHBSDKNetworkManager

+ (DHBSDKNetworkType)networkType {
    //huozhu0603
    DHBSDKNetworkType netWorkState;
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    switch (reachability.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            //无网络连接
            NSLog(@"Network NotReachable!");
            netWorkState = DHBSDKNetworkTypeNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            //使用3g网络
            NSLog(@"Network wwan!");
            netWorkState = DHBSDKNetworkTypeViaWWAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            //使用wifi
            NSLog(@"Network wifi!");
            netWorkState = DHBSDKNetworkTypeViaWiFi;
            break;
        default:
            break;
    }
    return netWorkState;
}
@end
