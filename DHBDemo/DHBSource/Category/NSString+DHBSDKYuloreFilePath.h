//
//  NSString+YuloreFilePath.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 14/9/4.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DHBSDKYuloreFilePath)
//+ (NSString *)pathForServiceIconDirectory;
+ (NSString *)pathForOfflineDataDirectory;
+ (NSString *)pathForOfflineDataDirectoryWithFileName:(NSString *)fileName;

+ (NSString *)pathForResolveCachesDirectory;

+ (NSString *)pathForUserPathHelperCachesDirectory;
+ (NSString *)pathForFavoriteHelperCachesDirectory ;
+ (NSString *)pathForOriginalCategoryDataFile;
+ (NSString *)pathForCategoryDataFileWithCityID:(NSString *)cityID;
+ (NSString *)pathForOfflineLOGOWithShopID:(NSString *)shopID;

+ (NSString *)pathForFullOfflineFilePath;
+ (NSString *)pathForDeltaOfflineFilePath;
+ (NSString *)pathForPreOfflineFilePath;
+ (NSString *)pathForBackupTempOfflineFilePath;
+ (NSString *)pathForBridgeOfflineFilePath;

@end
