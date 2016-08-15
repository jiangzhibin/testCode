//
//  NSString+YuloreFilePath.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 14/9/4.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "NSString+DHBSDKYuloreFilePath.h"

@implementation NSString (DHBSDKYuloreFilePath)


+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directoryConstant domainMask:(NSSearchPathDomainMask)domainMask
{
  NSFileManager* sharedFM = [NSFileManager defaultManager];
  NSArray *possiblepaths = [sharedFM URLsForDirectory:directoryConstant
                                            inDomains:domainMask];
  NSURL *path = nil;
  
  if ([possiblepaths count] >= 1) {
    // Use the first directory (if multiple are returned)
    path = [possiblepaths objectAtIndex:0];
  }
  
  return path.path;
}

+ (NSString *)pathForLibraryDirectory {
  return [self pathForDirectory:NSLibraryDirectory domainMask:NSUserDomainMask];
}

+ (NSString *)pathForUserPathHelperCachesDirectory {
  return [[self pathForLibraryDirectory] stringByAppendingString:@"/Caches/UserPath/"];
}


+ (NSString *)pathForOfflineDataDirectory {
  return [[self pathForLibraryDirectory] stringByAppendingString:@"/Caches/OfflineData/"];
}
////Caches/ServiceIcon
//+ (NSString *)pathForServiceIconDirectory {
//  
//  return [[self pathForLibraryDirectory] stringByAppendingString:@"/Caches/ServiceIcon/"];
//}




+ (NSString *)pathForOfflineDataDirectoryWithFileName:(NSString *)fileName{
  return [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:fileName];
}

/**
 *  pathForOfflineLOGOFile
 *
 *  @return pathForOfflineLOGOFile
 */
+ (NSString *)pathForOfflineLOGOWithShopID:(NSString *)shopID {
  return [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"logo/%@", shopID]];
}



/**
 *  CATEGORY
 */

+ (NSString *)pathForOriginalCategoryDataFile {
  NSString *path = [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"c0.json"]];
  return path;
}


+ (NSString *)pathForCategoryDataFileWithCityID:(NSString *)cityID {
  NSString *fileName = [NSString stringWithFormat:@"category%@.dat", cityID];
  NSString *cityCategoryFilePath = [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:fileName];
 
  if ([[NSFileManager defaultManager] fileExistsAtPath:cityCategoryFilePath]) {
    return cityCategoryFilePath;
  }else {
    return [self pathForOriginalCategoryDataFile];
  }
  
}




+ (NSString *)pathForDocumentDirectory {
    //NSFileManager* sharedFM = [NSFileManager defaultManager];
    //return [sharedFM containerURLForSecurityApplicationGroupIdentifier:@"group.yulore"].path;
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
}

+ (NSString *)pathForBackupTempOfflineFilePath {
    return [NSTemporaryDirectory() stringByAppendingString:@"/BackupOfflineFile"];
}

+ (NSString *)pathForBridgeOfflineFilePath {
    return [[self pathForDocumentDirectory] stringByAppendingString:@"/BridgeFile"];
}

+ (NSString *)pathForDeltaOfflineFilePath {
    return [[self pathForDocumentDirectory] stringByAppendingString:@"/DeltaFile"];
}

+ (NSString *)pathForFullOfflineFilePath {
    return [[self pathForDocumentDirectory] stringByAppendingString:@"/OfflineFile"];
}


+ (NSString *)pathForPreOfflineFilePath {
    return [[self pathForDocumentDirectory] stringByAppendingString:@"/PreOfflineFile"];
}


@end
