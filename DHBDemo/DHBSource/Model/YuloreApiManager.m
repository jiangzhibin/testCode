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

/// ApiKey & Signature
static NSString * const kApiKeyString               = @"DHBSDKApiKeyString";
static NSString * const kSignatureString            = @"DHBSDKSignatureString";

/// 经纬度
static NSString * const kCoordinatelatitude         = @"kDHBSDKCoordinatelatitude";
static NSString * const kCoordinatelongitude        = @"kDHBSDKCoordinatelongitude";

/// CityId
static NSString * const kCityId                     = @"kDHBSDKCityId";

/// 下载网络类型
static NSString * const kDownloadNetworkType        = @"kDHBSDKDownloadNetworkType";


@interface YuloreApiManager ()

@end
@implementation YuloreApiManager
+ (instancetype)sharedYuloreApiManager {
  static YuloreApiManager *apiManager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      apiManager = [YuloreApiManager new];
      [apiManager initializeValues];
      
  });
  return apiManager;
}

- (void)initializeValues {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 经纬度
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [userDefaults doubleForKey:kCoordinatelatitude];
    coordinate.longitude = [userDefaults doubleForKey:kCoordinatelongitude];
    _coordinate = coordinate;
    
    // 城市id
    NSString *cityId = [userDefaults objectForKey:kCityId];
    _cityId = cityId ? [cityId copy] : @"0";
    
    // apikey & signature
    _apiKey = [[userDefaults objectForKey:kApiKeyString] copy];
    _signature = [[userDefaults objectForKey:kSignatureString] copy];
    
    // 网络类型 (未设置过，则为0，代表DownloadNetworkTypeWifiOnly 仅wifi)
    _downloadNetworkType = [userDefaults integerForKey:kDownloadNetworkType];
}

#pragma mark - properties getter && setter

/**
 设置城市id

 @param cityId 城市id
 */
- (void)setCityId:(NSString *)cityId {
    if (_cityId != cityId) {
        _cityId = [cityId copy];
        [[NSUserDefaults standardUserDefaults] setObject:cityId ?: @"0" forKey:kCityId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 设置经纬度

 @param coordinate 经纬度
 */
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_coordinate.latitude != coordinate.latitude
        && _coordinate.longitude != coordinate.longitude) {
        _coordinate = coordinate;
        [[NSUserDefaults standardUserDefaults] setDouble:coordinate.latitude forKey:kCoordinatelatitude];
        [[NSUserDefaults standardUserDefaults] setDouble:coordinate.longitude forKey:kCoordinatelongitude];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/**
 设置ApiKey

 @param apiKey apiKey
 */
- (void)setApiKey:(NSString *)apiKey {
    if (_apiKey != apiKey) {
        _apiKey = [apiKey copy];
        [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:kApiKeyString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/**
 设置Signature

 @param signature signature
 */
- (void)setSignature:(NSString *)signature {
    if (_signature != signature) {
        _signature = [signature copy];
        [[NSUserDefaults standardUserDefaults] setObject:signature forKey:kSignatureString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setDownloadNetworkType:(DownloadNetworkType)downloadNetworkType {
    if (_downloadNetworkType != downloadNetworkType) {
        _downloadNetworkType = downloadNetworkType;
        [[NSUserDefaults standardUserDefaults] setInteger:downloadNetworkType forKey:kDownloadNetworkType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 摘取自YuloreAPI.m
+ (BOOL) registerInfoApikey:(NSString *)apikey
                  signature:(NSString *)signature {
    
    BOOL registered = NO;
    
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    id __apikey = [pref objectForKey:kApiKeyString];
    
    if (__apikey) {
        registered = YES;
    }
    
    [YuloreApiManager sharedYuloreApiManager].apiKey = apikey;
    [YuloreApiManager sharedYuloreApiManager].signature = signature;
    
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
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    
    id __apikey = [pref objectForKey:kApiKeyString];
    id __signature = [pref objectForKey:kSignatureString];
    if (__apikey == nil || __signature == nil) {
        return NO;
    }
    
    if ([[YuloreApiManager sharedYuloreApiManager].cityId isEqualToString:@"0"]) {
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
    }
    else {
        [self copyInitDataCompletionBlock:^(NSError *error) {
            completionBlock(error);
        }];
    }
    return YES;
}

@end
