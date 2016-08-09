//
//  YuloreApiManager.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/8.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "YuloreApiManager.h"
#import "NSString+YuloreFilePath.h"
#import "StartLoadingService.h"
#import "CityHelper.h"
#import "Commondef.h"

@interface YuloreApiManager ()


@end
@implementation YuloreApiManager
+ (instancetype)sharedYuloreApiManager {
  static YuloreApiManager *instance;
  

  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      instance = [YuloreApiManager new];
  });
  return instance;
}



#pragma mark - 来自YuloreAPI.m

+ (BOOL) registerInfoApikey:(NSString *)apikey
                  signature:(NSString *)signature {
    
    BOOL registered = NO;
    
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    
    id __apikey = [pref objectForKey:@"APIKEY"];
    
    if (!__apikey) {
        [pref setObject:apikey forKey:@"APIKEY"];
    } else {
        registered = YES;
        
    }
    
    
    DLog(@"SDK ------ apikey : %@",  [apikey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    id __signature = [pref objectForKey:@"SIGNATURE"];
    
    
    if (!__signature) {
        [pref setObject:signature forKey:@"SIGNATURE"];
    }
    
    
    
    return registered;
    
}




+ (void)copyInitDataCompletionBlock:(void (^)(NSError *error) )completionBlock  {
    
    
    dispatch_queue_t q = dispatch_queue_create("queue", 0);
    dispatch_async(q, ^{
        
        
        [StartLoadingService copyInitDataCompletionBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // [StartLoadingService cacheCategoyDataFromInternet];
                [StartLoadingService updateLastVersion];
                completionBlock(nil);
            });
        }];
        
        
        //    dispatch_async(dispatch_get_main_queue(), ^{
        //      completionBlock(nil);
        //    });
    });
}


+ (BOOL)existedFolder
{
    BOOL isDir = NO;
    NSString *createFolder = [NSString pathForOfflineDataDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createFolder isDirectory:&isDir];
    
    
    return existed;
}
+ (BOOL)registered {
    NSString *appkey = [YuloreApiManager sharedYuloreApiManager].apiKey;
    NSString *signature = [YuloreApiManager sharedYuloreApiManager].signature;
    if (appkey == nil || signature == nil
        || [appkey isKindOfClass:[NSNull class]] || [signature isKindOfClass:[NSNull class]]
        || [[appkey stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] || [[appkey stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        return NO;
    }
    
    if ([[CityHelper selectedCity] isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}


+ (BOOL) registerApp:(NSString *)apikey
           signature:(NSString *)signature
     completionBlock:(void (^)(NSError *error) )completionBlock {
    
    
    
    BOOL needToUpdate = [StartLoadingService fetcherLastVersion];
    BOOL registered = [self registerInfoApikey:apikey signature:signature];
    
    
    if (!needToUpdate && registered) {
        
        
        
        if (![self existedFolder]) {
            [self copyInitDataCompletionBlock:^(NSError *error) {
                completionBlock(error);
            }];
        }
        else {
            completionBlock(nil);
        }
        return YES;
    }
    else {
        [self copyInitDataCompletionBlock:^(NSError *error) {
            completionBlock(error);
        }];
    }
    return YES;
}


@end
