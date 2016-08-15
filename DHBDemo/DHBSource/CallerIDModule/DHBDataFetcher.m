//
//  DHBDataFetcher.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "DHBDataFetcher.h"

#import "DHBSDKUpdateItem.h"
#import "DHBSDKOpenUDID.h"
#import "DHBHTTPSessionManager.h"
#import "NSDictionary+DHBSDKSignature.h"
#import "DHBCovertIndexContent.h"
#import "YuloreApiManager.h"

@interface DHBDataFetcher()
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *parametersFull;
@end
@implementation DHBDataFetcher

+ (instancetype)sharedInstance {
  static DHBDataFetcher *_sharedListFetcher = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedListFetcher = [[DHBDataFetcher alloc] init];
  });
  
  return _sharedListFetcher;
}


/**
 apikey:mtyFwikuZ8ARgmwhljlidzxbevhrWrjL
 ver:1.1
 uid:123
 app:ios
 sig:17cc327af263c792cbf8d983729270cf
 debug:
 */
- (instancetype)init {
  self = [super init];
  if (self) {
    _parameters = [NSMutableDictionary dictionary];
    _parameters[@"apikey"] = [YuloreApiManager sharedYuloreApiManager].apiKey;
    _parameters[@"ver"] = [self versionString];
    _parameters[@"uid"] = [self uid];
    _parameters[@"app"] = [self appName];
    _parameters[@"v"] = [self apiVersion];
    _parameters[@"flag_ver"] = [self dataVersion];
    _parameters[@"sig"] = [_parameters signature];
    
    
    _parametersFull = [NSMutableDictionary dictionary];
    _parametersFull[@"apikey"] = [YuloreApiManager sharedYuloreApiManager].apiKey;
    _parametersFull[@"ver"] = [self versionString];
    _parametersFull[@"uid"] = [self uid];
    _parametersFull[@"app"] = [self appName];
    _parametersFull[@"v"] = [self apiVersion];
    _parametersFull[@"flag_ver"] = [self dataVersion];
    _parametersFull[@"sig"] = [_parametersFull signature];

  }
  return self;
  
}

/**
 *  api接口的版本
 *
 *  @return api接口的版本
 */
- (NSString *)apiVersion {
  return @"3";
}

/**
 *  app的版本
 *
 *  @return app的版本
 */
- (NSString *)versionString {
  NSString *ver = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"]];
  return ver;
}



/**
 *  app的版本
 *
 *  @return app的版本
 */
- (NSString *)dataVersion {
  return [[NSString alloc] initWithFormat:@"%ld",[[DHBCovertIndexContent sharedInstance] resolveDataFile].currentVersion];
//  return [DHBInitBusiness dateStringSetuped];
}

/**
 *  用户ID
 *
 *  @return 用户ID
 */
- (NSString *)uid {
  
  return [DHBSDKOpenUDID value];
}

/**
 *  app包名
 *
 *  @return com.yulore.callerid
 */
- (NSString *)appName {
  NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleIdentifier"];
  return appName;
}


- (NSArray *)offlineData {
  NSData *data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"init.json" ofType:nil]];
    
    if (data==nil){
        return [[NSArray alloc] init];
    }
  NSError *error = nil;
  id result = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                error:&error];
  NSMutableArray *items = [[NSMutableArray alloc] init];
  NSArray *list = result[@"data"];
  for (id aData in list) {
    
    DHBSDKUpdateItem *aItem = [DHBSDKUpdateItem itemWithDictionary:aData];
    [items addObject:aItem];
    
  }
  
  return items;
}

- (void)fullDataFetcherCompletionHandler:(void (^)( NSArray *fullPackageList, NSArray *deltaPackageList , NSError *error) )completionHandler {
  
//  __block NSArray *fulls = nil;//change here to enable default data
  __block NSArray *deltas = nil;
  
  /*[self onlyfullDataFetcherCompletionHandler:^(NSArray *fullPackageList, NSError *error) {
    fulls = fullPackageList;
    
    if (fulls != nil  && error == nil) {
      completionHandler(fulls,deltas , nil);
    }
    else if (error) {
      completionHandler(nil,nil , error);
    }
    
  }];*/
    NSLog(@"checkUpdate S");
  [self dataFetcherCompletionHandler:^(NSArray *results, NSError *error) {
    deltas =  results;
    if (deltas != nil && error == nil) {
        completionHandler(nil,deltas , nil);
        NSLog(@"checkUpdate 0");
    }
    else if (error) {
        completionHandler(nil,nil , error);
        NSLog(@"checkUpdate 1");
    }
    else {
        completionHandler(nil,nil,nil);
        NSLog(@"checkUpdate 2");
    }
  }];
}
/**
 *  数据获取器的回调
 *
 *  @param completionHandler 返回结果与错误
 */
/*
- (void)onlyfullDataFetcherCompletionHandler:(void (^)( NSArray *fullPackageList, NSError *error) )completionHandler {
    NSLog(@"onlyfullDataFetcherCompletionHandler");

  dispatch_queue_t q = dispatch_queue_create("com.yulore.callerid.datafetcher", 0);
  dispatch_async(q, ^{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString =  [dateFormatter stringFromDate:[NSDate date]];
      NSLog(@"onlyfullDataFetcherCompletionHandler async");

    
    _parametersFull[@"data_ver"] = dateString;
    _parametersFull[@"sig"] = [_parametersFull signature];
    [[DHBHTTPSessionManager sharedManager] dataWithParameters:_parametersFull URLString:@"chkdata/" completionHandler:^(NSDictionary *result, NSError *error) {

      if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSError *jsonError = nil;
          NSMutableArray *items = [[NSMutableArray alloc] init];
          NSArray *list = result[@"data"];
          for (id aData in list) {
            
            DHBUpdateItem *aItem = [DHBUpdateItem itemWithDictionary:aData];
            [items addObject:aItem];
            
          }
          completionHandler(items, error);
          
        });
      } else {
        completionHandler(nil, error);
      }
    }];
  });
  
 
  
}*/
- (void)dataFetcherCompletionHandler:(void (^)( NSArray *results, NSError *error) )completionHandler {
  
  dispatch_queue_t q = dispatch_queue_create("com.yulore.callerid.datafetcher", 0);
  dispatch_async(q, ^{
    _parameters[@"flag_ver"] = [self dataVersion];
    _parameters[@"sig"] = [_parameters signature];
    [[DHBHTTPSessionManager sharedManager] dataWithParameters:_parameters URLString:@"chkdata/" completionHandler:^(NSDictionary *result, NSError *error) {
      
      if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSError *jsonError = nil;
          NSMutableArray *items = nil;
          if (result[@"flag"]) {
              NSLog(@"FLAG AVAILABLE");
            items = [[NSMutableArray alloc] init];
            
            DHBSDKUpdateItem *aItem = [DHBSDKUpdateItem itemWithDictionary:result[@"flag"]];
            [items addObject:aItem];
            [aItem print];
          }
          completionHandler(items, error);
        });
      } else {
          NSLog(@"FLAG CHECK ERROR");
          completionHandler(nil, error);
      }
    }];
  });
  
  
}



@end


