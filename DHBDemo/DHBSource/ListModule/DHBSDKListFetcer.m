//
//  ListFetcer.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-17.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "CommonTmp.h"
#import "Commondef.h"
#import "DHBSDKListFetcer.h"
#import "DHBSDKShopItem.h"
#import "DHBSDKServicesItem.h"
#import "DHBSDKCategoryItem.h"
#import "NSDictionary+DHBSDKOffset.h"
#import "OfflineDataHelper.h"
#import "DHBSDKCategoryFetcer.h"
#include <string.h>

#import "DHBSDKAPIDotDianHuaDotCNClient.h"
#import "DHBSDKCustomItem.h"

static NSInteger CACHE_INTERVAL_DAY = 10;
@implementation DHBSDKListFetcer

+ (BOOL)isJsonHasCategory:(DHBSDKCategoryItem *)categoryItem {
  NSData *categoryJsonData = [OfflineDataHelper dataOfFilePath:DHBSDKDataCategory];

  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:categoryJsonData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
  
  NSArray *allKeys = [results allKeys];
  
  NSString *currentCategoryID = [NSString stringWithFormat:@"%@", categoryItem.categoryID ];
  BOOL flag = [allKeys containsObject:currentCategoryID];
  
  return flag;
}

//离线列表

+ (NSMutableArray *)executeFectcerFromCategoryJson:(DHBSDKCategoryItem *)categoryItem {
  NSMutableArray *shopItemsUnSort = [[NSMutableArray alloc] init];
  
  NSMutableArray * allCategorysArray = [DHBSDKCategoryFetcer sharedCategoryFetcer].categoryDataValue;
  NSMutableDictionary *allCategorysDic = [[NSMutableDictionary alloc] init];
  
  
  
  [allCategorysArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSString *key = [[NSString alloc] initWithFormat:@"%@",[obj valueForKey:@"id"]];
    
    [allCategorysDic setObject:obj forKey:key];
  }];
  
  NSData *categoryJsonData = [OfflineDataHelper dataOfFilePath:DHBSDKDataCategory];
  
  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:categoryJsonData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
  
  NSMutableArray *result = [[NSMutableArray alloc] init];
  
  NSArray *allKeys = [results allKeys];
    NSString *currentCategoryID = nil;
    if ([categoryItem isKindOfClass:[DHBSDKCategoryItem class]]) {
        currentCategoryID = [NSString stringWithFormat:@"%@", categoryItem.categoryID];
    }
    else if (([categoryItem isKindOfClass:[DHBSDKServicesItem class]])){
        DHBSDKServicesItem *servicesItem = (DHBSDKServicesItem *)categoryItem;
        currentCategoryID = [NSString stringWithFormat:@"%@", servicesItem.servicesID];
    }

  BOOL flag = [allKeys containsObject:currentCategoryID];
  if (flag) {
    
    NSDictionary *results2 =  [NSDictionary categorysWithOffset:[[results valueForKey:currentCategoryID] intValue]
                                                       filePath:[OfflineDataHelper dataFilePath:DHBSDKDataCategoryDat]];

    NSArray *listArray = (NSArray*) results2;

    NSMutableDictionary *categoryDic  = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [listArray count]; i+=2) {
      NSDictionary *shopItemDic = [NSDictionary dictionaryWithOffset:[[listArray objectAtIndex:i] integerValue]
                                                            filePath:[OfflineDataHelper dataFilePath:DHBSDKDataDetail]];
      // DHBSDKDLog(@"%@", shopItemDic);
      DHBSDKShopItem *aShopItems = [DHBSDKShopItem shopItemWithDictionary:shopItemDic];
      [shopItemsUnSort addObject:aShopItems];

      //DHBSDKDLog(@"%@", [NSString stringWithFormat:@"%@", aShopItems.categoryIDs.firstObject]);
      [categoryDic setValue:[NSString stringWithFormat:@"%@", aShopItems.categoryIDs.firstObject]
                     forKey:[NSString stringWithFormat:@"%@", aShopItems.categoryIDs.firstObject]];
      
    }
    DHBSDKDLog(@"category set %@", [categoryDic allKeys]);
    
    
    NSMutableArray *categoryHasCategory = [[NSMutableArray alloc] init];
    for (NSString *categoryID in [categoryDic allKeys]) {
      NSDictionary *aCategoryDic  = allCategorysDic[categoryID];
      if (aCategoryDic == nil) {
        continue;
      }
      [categoryHasCategory addObject:aCategoryDic];
    }

    NSMutableDictionary *shopItemDic = [[NSMutableDictionary alloc] init];
    
    
    // NSArray *rr = [dispgrpKV allKeys];
    for (DHBSDKShopItem *aShopItem in shopItemsUnSort) {
      for (NSDictionary *attributes in categoryHasCategory)  {
        //122 CategoryID
        NSString *dispID = [NSString stringWithFormat:@"%@", attributes[@"id"]];
        NSMutableArray *shopItems = shopItemDic[attributes];
        
        // for (id cID in aShopItem.categoryIDs) {
        NSString *categoryID = [NSString stringWithFormat:@"%@", aShopItem.categoryIDs.firstObject];
        //[NSString stringWithFormat:@"%@", cID];
        
        if ([categoryID isEqualToString:dispID]) {
          if (shopItems) {
            [shopItems addObject:aShopItem];
          } else {
            shopItems = [[NSMutableArray alloc] init];
            [shopItems addObject:aShopItem];
            [shopItemDic setObject:shopItems forKey:attributes];
          }
          break;
        }
        //}
      }
    }
    
    
    for (NSDictionary *attributes in categoryHasCategory) {
      
      NSDictionary *dic = [NSDictionary dictionaryWithObject:shopItemDic[attributes] forKey:attributes];
      [result addObject:dic];
    }
    
  }

  [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSInteger shops1count = [[[obj1 allValues] firstObject] count];
    NSInteger shops2count = [[[obj2 allValues] firstObject] count];
    
    if (shops1count  >  shops2count) {
      return (NSComparisonResult)NSOrderedDescending;
    }
    
    if (shops1count < shops2count) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
  }];

  return result;
}


+ (void)processWithJSON:(id)JSON
                  block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block {
  if ([[JSON valueForKey:@"status"] integerValue] == 0) {
    
    NSArray *dispgrp = [JSON valueForKeyPath:@"dispgrp"];
    
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"itms"];
    
    

    
    NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
    
    
    for (NSDictionary *attributes in postsFromResponse) {
      DHBSDKShopItem *post = [DHBSDKShopItem shopItemWithDictionary:attributes];
      [mutablePosts addObject:post];
    }
    
    NSMutableDictionary *shopItemDic = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([dispgrp count]) {
      for (DHBSDKShopItem *aShopItem in mutablePosts) {
        
        for (NSDictionary *attributes in dispgrp)  {
          
          NSString *dispID = [NSString stringWithFormat:@"%@", attributes[@"id"]];
          NSMutableArray *shopItems = shopItemDic[attributes];
          
          for (id cID in aShopItem.categoryIDs) {
            NSString *categoryID = [NSString stringWithFormat:@"%@", cID];
            
            if ([categoryID isEqualToString:dispID]) {
              if (shopItems) {
                [shopItems addObject:aShopItem];
              } else {
                shopItems = [[NSMutableArray alloc] init];
                [shopItems addObject:aShopItem];
                // DHBSDKDLog(@"attributes -2- %@", attributes);
                [shopItemDic setObject:shopItems forKey:attributes];
              }
              break;
            }
          }
        }
      }
      
      
      for (NSDictionary *attributes in dispgrp) {
        if (shopItemDic[attributes]) {
          
          NSDictionary *dic = [NSDictionary dictionaryWithObject:shopItemDic[attributes] forKey:attributes];
          [result addObject:dic];
        }
      }
      
      
    } else {
      [shopItemDic setObject:mutablePosts forKey:@{@"id": @"2", @"name":@"常用号码"}];
      [result addObject:shopItemDic];
      
    }
    
    
    NSMutableArray *customItems = [[NSMutableArray alloc] init];
    NSArray *postsFromResponse2 = [JSON valueForKeyPath:@"customs"];
    
    for (NSDictionary *attributes in postsFromResponse2) {
      CustomItem *post = [[DHBSDKCustomItem alloc] initWithDictionary:attributes];
      [customItems addObject:post];
      //[customItems insertObject:post atIndex:0];
    }
    
    if ([customItems count]) {
      
      [result insertObject:[NSDictionary dictionaryWithObject:customItems
                                                       forKey:@{@"id": @"0", @"name":@"custom"}] atIndex:0];
    }
    
    if (block) {
      block([NSMutableArray arrayWithArray:result], nil);
    }
  } else {
    //DHBSDKDLog(@"eeee");
    NSString *description = [NSString stringWithFormat:@"服务器错误 code : %ld", (long)[[JSON valueForKey:@"status"] integerValue] ];
    
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description};
    NSError *error = [[NSError alloc] initWithDomain:@"domain" code:[[JSON valueForKey:@"status"] integerValue] userInfo:errorDictionary];
    if (block) {
      block([NSMutableArray array], error);
    }
    
  }
}

+ (void)cacheDataWithParameter:(NSDictionary *)parameter andData:(NSData *)data {

  NSString *dataFileName = parameter[kCAT_ID];
  NSString *sha1DataFileName = [dataFileName sha1String];
 // NSDate *nowData = [NSDate date];
 // NSTimeInterval nowTime = [nowData timeIntervalSince1970];
 // NSString *fileName = [sha1DataFileName stringByAppendingFormat:@"%ld",(long)nowTime];
  NSString *filePath = [NSString pathForOfflineDataDirectoryWithFileName:sha1DataFileName];

  
  
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSError *error = nil;
  
  if ([fileManager fileExistsAtPath:filePath]) {
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    NSDate * modificationDate = [attributes objectForKey:NSFileModificationDate];
    NSTimeInterval timeinterval = [modificationDate timeIntervalSinceDate:[NSDate date]];
    
    CGFloat days = timeinterval / 3600. / 24;
    DHBSDKDLog(@"%lf days", days);
    if (days > CACHE_INTERVAL_DAY) {
      [data writeToFile:filePath atomically:YES];
    }
  }
  else {
    [data writeToFile:filePath atomically:YES];
  }

 
}


+ (BOOL)needToCacheJsonData:(NSDictionary *)param cachePath:(NSString **)cachePath{
  NSString *dataFileName = param[kCAT_ID];
  NSString *sha1DataFileName = [dataFileName sha1String];

  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSError *error = nil;
  
  NSArray *contentArray = [fileManager contentsOfDirectoryAtPath:[NSString pathForOfflineDataDirectory] error:&error];
  __block NSString *existFileName = nil;
  [contentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj hasPrefix:sha1DataFileName]) {
      existFileName = obj;
      *stop = YES;
    }
  }];
  
  

  if (!existFileName) {
    return YES;
  }
  

  NSString *timeStamp = [existFileName stringByReplacingOccurrencesOfString:sha1DataFileName withString:@""];
  NSTimeInterval ago = [[NSDate date] timeIntervalSince1970] - [timeStamp doubleValue];
  
  CGFloat days = ago / 3600.f / 24.f;
  if (days > 10) {
    return YES;
  }
  else {
    return YES;
  }
  
}


+ (void)loadCacheDataWithParam:(NSMutableDictionary *)param
                    fileExists:(BOOL *)fileExists
                         block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block {
  
  NSString *dataFileName = param[kCAT_ID];
  NSString *sha1DataFileName = [dataFileName sha1String];

  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSError *error = nil;
  
  NSArray *contentArray = [fileManager contentsOfDirectoryAtPath:[NSString pathForOfflineDataDirectory] error:nil];
  
  
  __block NSString *existFileName = nil;
  [contentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj hasPrefix:sha1DataFileName]) {
      existFileName = obj;
      *stop = YES;
    }
  }];
  
  
  
  if (existFileName == nil) {
    *fileExists = NO;
    error = [[NSError alloc] initWithDomain:@"Cache Data is not exist" code:8000 userInfo:nil];
    return;
  }
  
  NSString *filePath = [NSString pathForOfflineDataDirectoryWithFileName:existFileName];

  if ([fileManager fileExistsAtPath:filePath]) {
    *fileExists = YES;
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    [self processWithJSON:json block:^(NSMutableArray *shopItems__, NSError *error) {
      block(shopItems__, error);
    }];
  }
  else {
    error = [[NSError alloc] initWithDomain:@"Cache Data is not exist" code:8000 userInfo:nil];
  }
  
}
+ (void)shopItemsWithParam:(NSMutableDictionary *)param
                     block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block {
  
  
  [[DHBSDKAPIDotDianHuaDotCNClient sharedClient] GET:@"list/" parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    DHBSDKDLog(@"%@", task.response.URL);
    [self processWithJSON:responseObject block:block];
    
    
    //   NSString *cachePath = nil;
    //  if ([self needToCacheJsonData:param
    //                  cachePath:&cachePath] ) {
    //    [self needToCacheJsonData:param cachePath:&cachePath];
    //    [self cacheDataWithParameter:param andData:operation.responseData];
    // }
    
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    DHBSDKDLog(@"%@", error);
    if (block) {
      
      block([NSMutableArray array], error);
    }
  }];
  
  

}



@end