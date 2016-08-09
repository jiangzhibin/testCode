//
//  YuloreAPI.h
//  DianHuaBangSDK
//
//  Created by Zhang Heyin on 14-4-22.
//  Copyright (c) 2014年 com.yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 电话帮SDK初始化类
 */
@interface YuloreAPI : NSObject
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
