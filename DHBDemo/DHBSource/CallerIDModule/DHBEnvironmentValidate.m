//
//  DHBEnvironmentValidate.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/12.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "DHBEnvironmentValidate.h"
#import "DHBErrorHelper.h"
#import "AFNetworkReachabilityManager.h"
#import "AFNetworking.h"
@implementation DHBEnvironmentValidate

+ (NSError *)errorWithCurrentReachable {
  
  NSError *error = nil;
  
  if ( [[AFNetworkReachabilityManager sharedManager] isReachable]) {
    
    //if (![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
      
    //    error = [DHBErrorHelper errorWithNetworkNotWiFi];
    //}

  }
  else {
    
    NSString *info = @"Network Reachability Status Not Reachable.";
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:info forKey:NSLocalizedDescriptionKey];
    
    error = [[NSError alloc] initWithDomain:AFURLRequestSerializationErrorDomain
                                       code:NSURLErrorCannotConnectToHost
                                   userInfo:errorDetail];
  }
  
  return error;
}

/**
 *  <#Description#>
 *
 *  @param validate <#validate description#>
 */
+ (BOOL)environmentValidate:(NSError **)error {
  
  BOOL result = YES;
  *error = [self errorWithCurrentReachable];
  if (*error) {
    //    validate(NO, error);
    result = NO;
    return result;
  }
  
  *error = [DHBErrorHelper errorWithBatteryLevel];
  if (*error) {
    //    validate(NO , error);
    result = NO;
  }
  
  //  validate(YES, nil);
  return result;
}
@end
