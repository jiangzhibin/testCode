//
//  NetworkManager.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/16.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKNetworkManager.h"
#import "AFNetworking.h"
#import "Reachability.h"

@implementation DHBSDKNetworkManager

+ (DHBSDKNetworkType)networkType {
    //huozhu0603
    DHBSDKNetworkType netWorkState;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            //无网络连接
            NSLog(@"Network NotReachable!");
            netWorkState = DHBSDKNetworkTypeNotReachable;
            break;
        case ReachableViaWWAN:
            //使用3g网络
            NSLog(@"Network wwan!");
            netWorkState = DHBSDKNetworkTypeViaWWAN;
            break;
        case ReachableViaWiFi:
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
