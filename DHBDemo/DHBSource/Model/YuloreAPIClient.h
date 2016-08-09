//
//  YuloreAPIClient.h
//  TestMuti1
//
//  Created by Zhang Heyin on 15/2/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "APIDotDianHuaDotCNClient.h"
#import "ResolveItemNew.h"
@interface YuloreAPIClient : APIDotDianHuaDotCNClient
//- (NSURLSessionDataTask *)categoriesWithCityID:(NSString *)cityID completionHandler:( void (^)(NSArray *results, NSError *error) )completionHandler;
//- (NSURLSessionDataTask *)listWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(NSArray *results, NSError *error) )completionHandler;
+ (YuloreAPIClient *)sharedClient;
- (void)listWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(NSMutableDictionary *results, NSError *error) )completionHandler;
- (void)categoriesWithCityID:(NSString *)cityID completionHandler:( void (^)(NSMutableDictionary *results, NSError *error) )completionHandler;
- (void)resolveTelenumberWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(ResolveItemNew *resolveItem, NSError *error) )completionHandler;
@end
