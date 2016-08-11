
//  StartLoadingService.m
//  yellopage
//
//  Created by Zhang Heyin on 14-3-28.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//
#import "CommonTmp.h"
#import "StartLoadingService.h"
#import "CategoryItem.h"

#import "OfflineDataHelper.h"
#import "ServicesItem.h"
#import "NearbyItem.h"

static NSString * const kLastVersion = @"DHBSDKLastVersion";

@implementation StartLoadingService



+ (void)updateLastVersion {
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kLastVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)fetcherLastVersion {
  BOOL needToUpdate = YES;
  NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
  
  NSString *lastVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kLastVersion];
  
  if (lastVersion) {
    
    
    
    if ([ver isEqualToString:lastVersion]) {
      needToUpdate = NO;
    } else {
      
      needToUpdate = YES;
    }
  }
  
  return needToUpdate;
}

/*
+ (void)startLocation {
  [[CurrentLocation sharedInstance] startingForLocation:^(CLLocation *currentLocation, City *currentCity, NSError *error) {
    
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    
    NSNumber *timer  = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    CLLocationCoordinate2D coordinate = currentLocation.coordinate;
    [pref setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"coordinatelatitude"];
    [pref setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"coordinatelongitude"];
    [pref setObject:timer forKey:@"lastlocatingtime"];
    [pref synchronize];
  }];
}
*/


/**
 *  @author Zhang  Heyin
 *
 *  对离线文件从app中复制到沙箱中，zip文件会解压缩。
 *
 *  @param completionBlock <#completionBlock description#>
 */
+ (void) copyInitDataCompletionBlock:(void (^)(NSError *error) )completionBlock {
  NSString *offlineDirectory = [NSString pathForOfflineDataDirectory];
  
  NSString *filename = nil;
  NSString *apiKey = [YuloreApiManager sharedYuloreApiManager].apiKey;
  if (apiKey.length > 0) {
    filename = [NSString stringWithFormat:@"0_%@_full.zip", [apiKey substringToIndex:4]];
  } else {
    return;
  }
  
  [self copyAndUpzipZipFileWithNameArray:@[@"service_icon.zip", filename]
                            targetFolder:offlineDirectory
                         completionBlock:^(NSError *error)
   {
     dispatch_queue_t q = dispatch_queue_create("queue", 0);
     dispatch_async(q, ^{
       
       // cityId：0 代表all
       [OfflineDataHelper decompressDatFileWithCityId:@"0"];
       
       dispatch_async(dispatch_get_main_queue(), ^{
         DLog(@"copyAndUpzipZipFileWithNameArray");
         completionBlock(nil);
       });
     });
   }];
  
  
}


+ (long long) fileSizeAtPath:(NSString*) filePath{
  NSFileManager* manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:filePath]){
    return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
  }
  return 0;
}



/**
 *    @brief    创建文件夹
 *
 *    @param     createDir     创建文件夹路径
 */
+ (BOOL)createFolder:(NSString *)createDir
{
  BOOL createdDir = NO;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&createdDir];
  if ( !(createdDir == YES && existed == YES) ) {
    createdDir = [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  return createdDir;
}


+ (void ) copyAndUpzipZipFileWithNameArray:(NSArray *)nameArray targetFolder:(NSString *)targetFolder

                           completionBlock:(void (^)(NSError *error) )completionBlock
{
  
  NSString *zipFileFolderPath = nil;
  
  if ([nameArray count] <= 0) {
    return;
  }
  
  zipFileFolderPath = [targetFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", nameArray[0]]];
  
  //  if ([[NSFileManager defaultManager] fileExistsAtPath:targetFolder]
  //      && ([self fileSizeAtPath:targetFolder] > 0)
  //      ) {
  //    DLog(@"文件已经存在了");
  //    completionBlock(nil);
  //    return;
  //  }else {
  int countFiles = 0;
  
  if ([self createFolder:targetFolder]) {
    for (NSString *fileName in nameArray) {
      countFiles++;
      NSString *resourceFolderPath =[[NSBundle mainBundle] pathForResource:fileName ofType:nil];
      NSData *mainBundleFile = [NSData dataWithContentsOfFile:resourceFolderPath];
      if ( [[NSFileManager defaultManager] createFileAtPath:zipFileFolderPath
                                                   contents:mainBundleFile
                                                 attributes:nil]) {
        //todo解压缩
        YuloreZipArchive *zip = [[YuloreZipArchive alloc] init];
        //   zip.progressBlock = progressBlock;
        zip.progressBlock = ^ (int percentage, int filesProcessed, int numFiles) {
          
          DLog(@"total %d, filesProcessed %d of %d", percentage, filesProcessed, numFiles);
          
          if (countFiles == nameArray.count && percentage == 100) {
            DLog(@"unzip finish!!!!!!");
            completionBlock(nil);
          }
        };
        BOOL result = NO;
        
        if ([zip UnzipOpenFile:zipFileFolderPath]) {
          
          result = [zip UnzipFileTo:targetFolder overWrite:YES];//解压文件
          if (!result) {
            //解压失败
            DLog(@"unzip fail................");
          }else {
            //解压成功
            DLog(@"unzip success.............");
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:zipFileFolderPath error:nil];
          }
          // YuloreZipArchiveProgressUpdateBlock progressBlock
          //DLog(@"total %d, filesProcessed %d of %d", percentage, filesProcessed, numFiles);
        }
        [zip UnzipCloseFile];//关闭
        
      }
    }
    //}
  }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  
  if (alertView.tag==10000) {
    if (buttonIndex==1) {
      
      NSURL *url = [NSURL URLWithString:self.trackViewUrl];
      [[UIApplication sharedApplication] openURL:url];
    }
  }
}

+ (void) nearbyImageCache:(NSArray *)nearbyArray {
  
  
  for (NearbyItem *aItem in nearbyArray) {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aItem.iconURLString]];
    
    
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                             
                             NSArray *urlArray = [aItem.iconURLString componentsSeparatedByString:@"/"];
                             NSString *fileName = [urlArray lastObject];
                             NSString *cacheFileNamePath = [[NSString pathForOfflineDataDirectory] stringByAppendingFormat:@"%@", fileName ];
                             [data writeToFile:cacheFileNamePath atomically:YES];
//                             DLog(@"%@ nearbyArray writeToFile", fileName);
                             //                             countsForUpdate--;
                             //                             if (countsForUpdate == 0) {
                             //                               completionHandler(nil);
                             //                             }
                           }];
  }
  
  
  
  
  
}
+ (void) cacheIconImageFromInternet:(NSArray *)contentArray
                        nearbyArray:(NSArray *)nearByArray
                         withPrefix:(NSString *)prefix
                  completionHandler:(void (^)(NSError *error))completionHandler {
  
  __block NSUInteger countsForUpdate = [contentArray count];
  //  __block int counter = 0;
  [self nearbyImageCache:nearByArray];
  if (countsForUpdate) {
    //  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:[contentArray count]];
    for (id aItem in contentArray) {
      NSString *urlString  = nil;
      NSString *itemID = nil;
      //DLog(@"aItem -- %@", aItem);
      if ([aItem isKindOfClass:[NSDictionary class]]) {
        if ( [[aItem allKeys] containsObject:@"icon"]) {
          [urlArray addObject:aItem[@"icon"]];
          urlString = aItem[@"icon"];
          itemID = aItem[@"id"];
        } else {
          return;
        }
        
      } else if ([aItem isKindOfClass:[ServicesItem class]]){
        urlString = ((ServicesItem *)aItem).iconURLString;
        itemID =  ((ServicesItem *)aItem).servicesID;
      } else if ([aItem isKindOfClass:[CategoryItem class]]){
        urlString = ((CategoryItem *)aItem).iconURLString;
        itemID =  ((CategoryItem *)aItem).categoryID;
      }
      
      
      
      
      
      NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
      
      
      
      [NSURLConnection sendAsynchronousRequest:urlRequest
                                         queue:[NSOperationQueue mainQueue]
                             completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSArray *urlArray = [urlString componentsSeparatedByString:@"/"];
                               NSString *fileName = [urlArray lastObject];
                               NSString *cacheFileNamePath = [[NSString pathForOfflineDataDirectory] stringByAppendingFormat:@"%@_%@",prefix, fileName ];
                               
                                [self createFolder:[NSString pathForOfflineDataDirectory]];
                               
                               

                               
                               BOOL cacheOK = [data writeToFile:cacheFileNamePath atomically:YES];
//                               DLog(@"%@ writeToFile, %@", fileName, (cacheOK ? @"YES": @"NO"));
                               countsForUpdate--;
                               if (countsForUpdate == 0) {
                                 completionHandler(nil);
                               }
                             }];
    }
    
    
    
  }
  
  
}





+ (void) cacheServiceIconImageFromInternet2:(NSArray *)serviceArray
                                nearbyArray:(NSArray *)nearByArray
                          completionHandler:(void (^)(NSError *error))completionHandler {
  
  [self cacheIconImageFromInternet:serviceArray
                       nearbyArray:nearByArray
                        withPrefix:@"sicon"
                 completionHandler:^(NSError *error) {
                   DLog(@"cacheServiceIconImageFromInternet2");
                   completionHandler(error);
                 }];
  
}

+ (void) cacheServiceIconImageFromInternet:(NSArray *)serviceArray {
  Reachability *reach = [Reachability reachabilityWithHostName:kHost];
  if ([reach isReachable]) {
    if ([serviceArray count]) {
      
      
      NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:[serviceArray count]];
      for (NSDictionary *aServiceItem in serviceArray) {
        if ([[aServiceItem allKeys] containsObject:@"icon"]) {
          [urlArray addObject:aServiceItem[@"icon"]];
        }
        
      }
      
      
      dispatch_queue_t q = dispatch_queue_create("queue", 0);
      dispatch_async(q, ^{
        for (NSString *urlString in urlArray) {
          
          NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
          
          
          NSArray *urlArray = [urlString componentsSeparatedByString:@"/"];
          NSString *fileName = [urlArray lastObject];
          NSString *cacheFileNamePath = [[NSString pathForOfflineDataDirectory] stringByAppendingFormat:@"/sicon_%@", fileName ];
          [data writeToFile:cacheFileNamePath atomically:YES];
        }
        
      });
      
    }
  }
}


+ (void) updateCurrentCity {
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(cacheCategoyDataFromInternet)
                                               name: @"cacheCategoyDataFromInternet"
                                             object: nil];
  
}


@end
