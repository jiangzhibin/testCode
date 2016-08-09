//
//  ListFetcer.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-17.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "CommonTmp.h"
#import "ListFetcer.h"
#import "ShopItem.h"
#import "ServicesItem.h"
#import "CategoryItem.h"
#import "SignatureHelper.h"
#import "NSDictionary+Offset.h"
#import "OfflineDataHelper.h"
#import "CategoryFetcer.h"
#include <string.h>

#import "CurrentLocation.h"
#import "APIDotDianHuaDotCNClient.h"
#import "CustomItem.h"

static NSInteger CACHE_INTERVAL_DAY = 10;
@implementation ListFetcer

+ (void)executeFectcerWithCategoryItem:(CategoryItem *)aCategoryItem block:(void (^)(NSMutableArray *, NSError *))block {
  Reachability * reach = [Reachability reachabilityWithHostName:kHost];
  
  CLLocationCoordinate2D  coordinate = [CurrentLocation currentCoordinate];
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [DHBSDKConfiguration shareInstance].cityId, kCITY_ID ,
                              //aCategoryItem.categoryID, CAT_ID,
                              @"20", kNUMBER,
                              @"0", kSTART ,
                              [OpenUDID value], kUID,
                              @"0", kSIGNATURE, nil];
  
  if (![aCategoryItem.categoryID isEqualToString:@"9999"]) {
    
    [dic setValue:aCategoryItem.categoryID forKey:kCAT_ID];
  } else {
    // [dic setValue:@"" forKey:CAT_ID];
    [dic setValue:@"0" forKey:kCITY_ID];
  }
  if ((aCategoryItem.location ||
       ([aCategoryItem.categoryID isEqualToString:@"9999"]))   &&
      coordinate.latitude != 0 &&
      coordinate.longitude != 0) {
    [dic setValue:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:kLAT];
    [dic setValue:[NSString stringWithFormat:@"%f",coordinate.longitude]  forKey:kLNG];
//    [dic setValue:@"2" forKey:kOLDER];
    [dic setValue:@"0" forKey:kSIGNATURE];
  }
  
  
  
  
  /**
   *  加载缓存中的list
   */
  
  BOOL isLoadFromCacheJsonData = NO;
  [self loadCacheDataWithParam:dic
                    fileExists:&isLoadFromCacheJsonData
                         block:^(NSMutableArray *shopItems__, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{

      block(shopItems__, error);
    });
  }];

  
  
  if ([reach isReachable]) {
    dispatch_queue_t q = dispatch_queue_create("com.yulore.yellowpage.online.selectcategory", 0);
    dispatch_async(q, ^{
      [ListFetcer executeFectcerWithInformation3:dic block:^(NSMutableArray *shopItems_, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          block(shopItems_, error);
        });
      }];
    });
    
  }
  else {
    /**
     *  如果已经有了缓存数据
     */
    if (isLoadFromCacheJsonData) {
      return;
    }
    
    
    if ([ListFetcer isJsonHasCategory:aCategoryItem] && [OfflineDataHelper hasCategoryData]) {
      
      
      dispatch_queue_t q = dispatch_queue_create("com.yulore.yellowpage.offline.selectcategory", 0);
      dispatch_async(q, ^{
        NSMutableArray *listArray = [ListFetcer executeFectcerFromCategoryJson:aCategoryItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          block(listArray, nil);
        });
      });
    }
    else {
      NSError *error = [[NSError alloc] initWithDomain:@"离线数据中不包含此分类数据" code:6002 userInfo:nil];
      block(nil, error);
    }
  }
}



+ (BOOL)isJsonHasCategory:(CategoryItem *)categoryItem {
  NSData *categoryJsonData = [OfflineDataHelper dataOfFilePath:DataCategory];

  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:categoryJsonData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
  
  NSArray *allKeys = [results allKeys];
  
  NSString *currentCategoryID = [NSString stringWithFormat:@"%@", categoryItem.categoryID ];
  BOOL flag = [allKeys containsObject:currentCategoryID];
  
  return flag;
}

//离线列表

+ (NSMutableArray *)executeFectcerFromCategoryJson:(CategoryItem *)categoryItem {
  NSMutableArray *shopItemsUnSort = [[NSMutableArray alloc] init];
  
  NSMutableArray * allCategorysArray = [CategoryFetcer sharedCategoryFetcer].categoryDataValue;
  NSMutableDictionary *allCategorysDic = [[NSMutableDictionary alloc] init];
  
  
  
  [allCategorysArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSString *key = [[NSString alloc] initWithFormat:@"%@",[obj valueForKey:@"id"]];
    
    [allCategorysDic setObject:obj forKey:key];
  }];
  
  NSData *categoryJsonData = [OfflineDataHelper dataOfFilePath:DataCategory];
  
  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:categoryJsonData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:nil];
  
  NSMutableArray *result = [[NSMutableArray alloc] init];
  
  NSArray *allKeys = [results allKeys];
    NSString *currentCategoryID = nil;
    if ([categoryItem isKindOfClass:[CategoryItem class]]) {
        currentCategoryID = [NSString stringWithFormat:@"%@", categoryItem.categoryID];
    }
    else if (([categoryItem isKindOfClass:[ServicesItem class]])){
        ServicesItem *servicesItem = (ServicesItem *)categoryItem;
        currentCategoryID = [NSString stringWithFormat:@"%@", servicesItem.servicesID];
    }

  BOOL flag = [allKeys containsObject:currentCategoryID];
  if (flag) {
    
    NSDictionary *results2 =  [NSDictionary categorysWithOffset:[[results valueForKey:currentCategoryID] intValue]
                                                       filePath:[OfflineDataHelper dataFilePath:DataCategoryDat]];

    NSArray *listArray = (NSArray*) results2;

    NSMutableDictionary *categoryDic  = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [listArray count]; i+=2) {
      NSDictionary *shopItemDic = [NSDictionary dictionaryWithOffset:[[listArray objectAtIndex:i] integerValue]
                                                            filePath:[OfflineDataHelper dataFilePath:DataDetail]];
      // DLog(@"%@", shopItemDic);
      ShopItem *aShopItems = [ShopItem shopItemWithDictionary:shopItemDic];
      [shopItemsUnSort addObject:aShopItems];

      //DLog(@"%@", [NSString stringWithFormat:@"%@", aShopItems.categoryIDs.firstObject]);
      [categoryDic setValue:[NSString stringWithFormat:@"%@", aShopItems.categoryIDs.firstObject]
                     forKey:[NSString stringWithFormat:@"%@", aShopItems.categoryIDs.firstObject]];
      
    }
    DLog(@"category set %@", [categoryDic allKeys]);
    
    
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
    for (ShopItem *aShopItem in shopItemsUnSort) {
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



+ (NSMutableArray *)executeFectcerWithInformation2:(NSString *)information {
  NSArray *result = [OfflineDataHelper pinyinIndexWithKeyWords:information];

  NSString *filePath = [NSString pathForOfflineDataDirectoryWithFileName:@"d0.dat"];
  
  FILE *fp = fopen([filePath UTF8String],"r");
  if (fp == NULL) {
    return nil;
  }

  int i = 0;
  
  NSMutableArray *shopItems = [[NSMutableArray alloc] init];
  for (NSDictionary *adic in result) {
    //DLog(@"%@", adic);
    
    NSDictionary *shopItemDic = [NSDictionary dictionaryWithOffset:[[adic objectForKey:dataoffset] intValue]
                                                          filePath:filePath];
    if (shopItemDic) {
      
      ShopItem *aShopItems = [ShopItem shopItemWithDictionary:shopItemDic];
      [shopItems addObject:aShopItems];
      i++;
      if (i > 50) {
        break;
      }
    }
    
  }
  
  return shopItems;
}

+ (void)processWithJSON:(id)JSON
                  block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block {
  if ([[JSON valueForKey:@"status"] integerValue] == 0) {
    
    NSArray *dispgrp = [JSON valueForKeyPath:@"dispgrp"];
    
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"itms"];
    
    

    
    NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
    
    
    for (NSDictionary *attributes in postsFromResponse) {
      ShopItem *post = [ShopItem shopItemWithDictionary:attributes];
      [mutablePosts addObject:post];
    }
    
    NSMutableDictionary *shopItemDic = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if ([dispgrp count]) {
      for (ShopItem *aShopItem in mutablePosts) {
        
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
                // DLog(@"attributes -2- %@", attributes);
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
      CustomItem *post = [[CustomItem alloc] initWithDictionary:attributes];
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
    //DLog(@"eeee");
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
    DLog(@"%lf days", days);
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
  
  
  [[APIDotDianHuaDotCNClient sharedClient] GET:@"list/" parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    DLog(@"%@", task.response.URL);
    [self processWithJSON:responseObject block:block];
    
    
    //   NSString *cachePath = nil;
    //  if ([self needToCacheJsonData:param
    //                  cachePath:&cachePath] ) {
    //    [self needToCacheJsonData:param cachePath:&cachePath];
    //    [self cacheDataWithParameter:param andData:operation.responseData];
    // }
    
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    DLog(@"%@", error);
    if (block) {
      
      block([NSMutableArray array], error);
    }
  }];
  
  

}

+ (void)executeFectcerWithInformation3:(NSMutableDictionary *)information
                                 block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block {
  
  NSString *sig2 = [SignatureHelper signatureWithDictionary:information];
  [information setValue:sig2 forKey:kSIGNATURE];
  [information setValue:[YuloreApiManager sharedYuloreApiManager].apiKey forKey:@"apikey"];
  
  

  
  [self shopItemsWithParam:information block:^(NSMutableArray *shopItems__, NSError *error) {
    block([NSMutableArray arrayWithArray:shopItems__], error);
  }];
  
  
}

+ (NSDictionary *)serverDictionaryInformation:(NSMutableDictionary *)information {
  NSString *sig2 = [SignatureHelper signatureWithDictionary:information];
  [information setValue:sig2 forKey:kSIGNATURE];
  //20140317
  [information setValue:[YuloreApiManager sharedYuloreApiManager].apiKey forKey:@"apikey"];
  NSString *baseURL = [NSString stringWithFormat:@"%@/list/",kHost];
  NSArray *allKey = [information allKeys];
  NSString *condition = [[NSString alloc] init];
  for (NSString *aKey in allKey) {
    condition = [condition stringByAppendingFormat:@"&%@", [NSString stringWithFormat:@"%@=%@", aKey, [information valueForKey:aKey]]];
  }
  baseURL = [baseURL stringByAppendingFormat:@"?%@", condition];
  baseURL = [baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:baseURL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error = nil;
  NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
  if (error) DLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
  
  return results;
  
}



+ (NSMutableArray *)executeFectcerWithInformation:(NSMutableDictionary *)information {
  
  
  NSMutableArray *listArray = [[self serverDictionaryInformation:information] valueForKey:@"itms"];
  
  NSMutableArray *shopItems = [[NSMutableArray alloc] init];
  // DLog(@"%@", listArray);
  
  for (NSDictionary *aItem in listArray) {
    ShopItem *aShopItems = [ShopItem shopItemWithDictionary:aItem];
    [shopItems addObject:aShopItems];
  }
  
  return shopItems;
}



@end
