//
//  CategoryFetcer.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/3/17.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//
#import "CommonTmp.h"
#import "Commondef.h"
#import "CategoryFetcer.h"
#import "YuloreAPIClient.h"
#import "CategoryItem.h"
#import "NearbyItem.h"
#import "ServicesItem.h"
#import "StartLoadingService.h"
#import "PromotionItem.h"
#define CATEGORY_KEY @"category"
#define SERVICE_KEY @"services"
#define LOCAL_SERVICE_KEY @"localsvcs"
#define NEARBY_KEY @"nearby"
#define PROMOTION_KEY @"promotions"
@implementation CategoryFetcer

+ (instancetype)sharedCategoryFetcer {
    static CategoryFetcer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CategoryFetcer new];
    });
    return instance;
}

- (void)buildJsonDataWithResult:(NSDictionary *)result
      categoryCompletionHandler:(CategoryAllCompletionHandler)categoryCompletionHandler  {
  
  self.categoryDataValue = [result objectForKey:CATEGORY_KEY];
  self.serviceDataValue = [result objectForKey:SERVICE_KEY];
  self.localServiceDataValue = [result objectForKey:LOCAL_SERVICE_KEY];
  self.nearbyDataValue = [result objectForKey:NEARBY_KEY];
  self.promotionsDataValue = [result objectForKey:PROMOTION_KEY];
  
  NSMutableArray *allCategories = [[NSMutableArray alloc] init];
  NSMutableArray *allHotCategories = [[NSMutableArray alloc] init];
  NSMutableArray *allLocalServices = [[NSMutableArray alloc] init];
  NSMutableArray *allServices = [[NSMutableArray alloc] init];
  NSMutableArray *allNearbys = [[NSMutableArray alloc] init];
  NSMutableArray *allPromotions = [[NSMutableArray alloc] init];
  [self.categoryDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    CategoryItem *aItem = [[CategoryItem alloc] initWithDictionary:obj];
    
    if ([[obj valueForKey:@"hot"] integerValue] == 1) {
      [allHotCategories addObject:aItem];
    }
    
    [allCategories addObject:aItem];
    
  }];
  
  [self.serviceDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    ServicesItem *aItem = [[ServicesItem alloc] initWithDictionary:obj];
    [allServices addObject:aItem];
    
  }];
  
  [self.localServiceDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    ServicesItem *aItem = [[ServicesItem alloc] initWithDictionary:obj];
    [allLocalServices addObject:aItem];
    
  }];
  
  [self.nearbyDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NearbyItem *aItem = [[NearbyItem alloc] initWithDictionary:obj];
    [allNearbys addObject:aItem];
  }];
  
  [self.promotionsDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    PromotionItem *aItem = [[PromotionItem alloc] initWithDictionary:obj];
    [allPromotions addObject:aItem];
  }];
  
  
  categoryCompletionHandler(allCategories, allHotCategories, allServices, allLocalServices, allNearbys ,allPromotions,nil);
}


- (void)categoryLoadFromSandboxCompletionHandler:(CategoryAllCompletionHandler)loadFromSandboxCompletionHandler withCityID:(NSString *)cityID {
  
  
  NSString *categoryPath = [NSString pathForCategoryDataFileWithCityID:cityID];
  NSData  *categoryData  = [NSData dataWithContentsOfFile:categoryPath];
  
  if (categoryData != nil) {
    
    NSError *error = nil;
    NSDictionary *results = categoryData ? [NSJSONSerialization JSONObjectWithData:categoryData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    
    
    
    if (!error) {
      
      [self buildJsonDataWithResult:results
          categoryCompletionHandler:^(NSMutableArray *allCategories,
                                      NSMutableArray *allHotCategories,
                                      NSMutableArray *allServices,
                                      NSMutableArray *allLocalServices,
                                      NSMutableArray *allNearbys,
                                      NSMutableArray *allPromotions,
                                      NSError *error) {
            DLog(@" loadFromSandboxCompletionHandler ");
            loadFromSandboxCompletionHandler(allCategories, allHotCategories, allServices, allLocalServices, allNearbys,allPromotions,error);
            
          }];
      
      
      
      
    } else
    {
      
      loadFromSandboxCompletionHandler(nil, nil, nil, nil, nil,nil, error);
      
    }
    
  }
}



- (void)categoriesFromeSandboxWithCityID:(NSString *)cityID
                       completionHandler:(CategoryAllCompletionHandler)completionHandler {
  dispatch_queue_t q = dispatch_queue_create("queue", 0);
  dispatch_async(q, ^{
    
    
    
    [self categoryLoadFromSandboxCompletionHandler:^(NSMutableArray *allCategories,
                                                     NSMutableArray *allHotCategories,
                                                     NSMutableArray *allServices,
                                                     NSMutableArray *allLocalServices,
                                                     NSMutableArray *allNearbys,
                                                     NSMutableArray *allPromotions,
                                                     NSError *error)
     {
       dispatch_async(dispatch_get_main_queue(), ^{
         
         completionHandler(allCategories, allHotCategories, allServices, allLocalServices,allNearbys,allPromotions, error);
         
       });
     } withCityID:cityID];
    
  });
}


- (void)categoriesWithCityID:(NSString *)cityID
loadFromSandboxCompletionHandler:(CategoryCompletionHandler)loadFromSandboxCompletionHandler
updateFromServerCompletionHandler:(CategoryCompletionHandler)updateFromServerCompletionHandler {
  
  [self categoriesFromeSandboxWithCityID:cityID
                       completionHandler:^(NSMutableArray *allCategories,
                                           NSMutableArray *allHotCategories,
                                           NSMutableArray *allServices,
                                           NSMutableArray *allLocalServices,
                                           NSMutableArray *allNearbys,
                                           NSMutableArray *allPromotions,
                                           NSError *error) {
                         
                         _allHotCategories = allHotCategories;
                         _allServices = allServices;
                         _allLocalServices = allLocalServices;
                         _allCategories = allCategories;
                         _allNearby = allNearbys;
                         _allPromotions = allPromotions;
                         loadFromSandboxCompletionHandler(allHotCategories, allServices, allLocalServices,allNearbys, allPromotions, error);
                         
                       }];
  
  [self categoriesWithCityID:cityID completionHandler:^(NSMutableArray *allCategories, NSMutableArray *allHotCategories, NSMutableArray *allServices, NSMutableArray *allLocalServices,NSMutableArray *allNearbys,NSMutableArray *allPromotions, NSError *error) {
    
    _allHotCategories = allHotCategories;
    _allServices = allServices;
    _allLocalServices = allLocalServices;
    _allCategories = allCategories;
    _allNearby = allNearbys;
    _allPromotions = allPromotions;
    updateFromServerCompletionHandler(allHotCategories, allServices, allLocalServices, allNearbys,allPromotions, error);
    
  }];
}

//
//- (void)cacheServiceIcon:(NSMutableArray *)allServices completionHandler:(void (^)(NSError *error))completionHandler  {
//
//  [StartLoadingService cacheServiceIconImageFromInternet2:allServices completionHandler:^(NSError *error) {
//    completionHandler(error);
//  }];
//}

- (NSString *)loadCategoryFilePathWithCityID:(NSString *)cityID {
  
  
  
  NSString *folderPath = [NSString stringWithFormat:@"/Caches/OfflineData/category%@.dat", cityID];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
  
  if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
    folderPath = [NSString pathForOriginalCategoryDataFile];
  }
  
  return folderPath;
}
- (void)cache:(NSMutableDictionary *)results withCityID:(NSString *)cityID {
  if ([results isKindOfClass:[NSDictionary class]]) {
    
    
    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:results options:0 error:nil];//[NSKeyedArchiver archivedDataWithRootObject:results];
    if (jsonData) {
      
      
      NSString *dataName = [NSString stringWithFormat:@"/Caches/OfflineData/category%@.dat", cityID];
      
      NSArray *paths = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory,NSUserDomainMask, YES);
      NSString *cacheDirectory = [paths objectAtIndex:0];
      //dbPath： 数据库路径，在Document中。
      NSString *filePath = [cacheDirectory stringByAppendingPathComponent:dataName];
      //  DLog(@"dataName %@", dataName);
      BOOL b = [jsonData writeToFile:filePath atomically:YES];
      DLog(@"CACHE CATEGORY DATA %@", b ? @"成功" : @"失败");
      
    }
  }
}
- (void)categoriesWithCityID:(NSString *)cityID
           completionHandler:(CategoryAllCompletionHandler)xcompletionHandler {
  
  
  dispatch_queue_t q = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
  
  
  dispatch_async(q, ^{
    
    
    
    [[YuloreAPIClient sharedClient] categoriesWithCityID:cityID
                                       completionHandler:^(NSMutableDictionary *results, NSError *error)
     {
       if (results) {
         
         [self cache:results withCityID:cityID];
         
         
         [self buildJsonDataWithResult:results
             categoryCompletionHandler:^(NSMutableArray *allCategories,
                                         NSMutableArray *allHotCategories,
                                         NSMutableArray *allServices,
                                         NSMutableArray *allLocalServices,
                                         NSMutableArray *allNearbys,
                                         NSMutableArray *allPromotions,
                                         NSError *error)
          {
            
            [StartLoadingService cacheServiceIconImageFromInternet2:allServices
                                                        nearbyArray:allNearbys
                                                  completionHandler:^(NSError *error) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      xcompletionHandler(allCategories, allHotCategories, allServices, allLocalServices,  allNearbys, allPromotions, error);
                                                      
                                                    });
                                                  }];
            
            // completionHandler(allHotCategories, allServices, allLocalServices, error);
          }];
       } else {
         
         xcompletionHandler(nil, nil,nil,nil,nil,nil, error);
         
       }
     }];
  });
  
  //
  //  dispatch_async(q, ^{
  //
  //    [StartLoadingService cacheServiceIconImageFromInternet2:aAllServices completionHandler:^(NSError *error) {
  //      dispatch_async(dispatch_get_main_queue(), ^{
  //        xcompletionHandler(aAllHotCategories, aAllLocalServices, aAllServices, error);
  //      });
  //    }];
  //
  //
  //    DLog(@"-----cacheServiceIconImageFromInternet2-----");
  //  });
  //
  
  
}

- (NSString *)catidWithData:(NSString *)urlformatted {
  //  NSString *urlformatted = [data stringByReplacingOccurrencesOfString:@"yulorepage-list:" withString:@""];
  
  NSArray *array = [urlformatted componentsSeparatedByString:@"&"];
  
  
//  NSInteger city_id = 0;
  
  NSString *cat_id = @"";
  for (NSString *keyValue in array) {
    NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
    if ([keyValueArray count] == 2) {
      NSString *key = keyValueArray[0];
      NSString *value = keyValueArray[1];
      
      if ([key isEqualToString:@"cat_id"]) {
        cat_id = value;
      }
    }
  }
  
  return cat_id;
  
}


- (NSMutableArray *)categoryDataValue {
  if (!_categoryDataValue) {
    NSString *categoryPath = [NSString pathForCategoryDataFileWithCityID:@"2"];
    NSData  *categoryData  = [NSData dataWithContentsOfFile:categoryPath];
    
    if (categoryData != nil) {
      
      NSError *error = nil;
      NSDictionary *results = categoryData ? [NSJSONSerialization JSONObjectWithData:categoryData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
     
      _categoryDataValue = results[@"category"];
      
    }
  }
  
  return _categoryDataValue;
}

- (NSMutableArray *)nearbyDataValue {
  if (!_nearbyDataValue) {
    NSString *nearbyPath = [NSString pathForCategoryDataFileWithCityID:@"2"];
    NSData  *nearbyData  = [NSData dataWithContentsOfFile:nearbyPath];
    
    if (nearbyData != nil) {
      
      NSError *error = nil;
      NSDictionary *results = nearbyData ? [NSJSONSerialization JSONObjectWithData:nearbyData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
      
      _nearbyDataValue = results[@"nearby"];
      
    }
  }
  
  return _nearbyDataValue;
}




- (void)loadingListViewControllerParamter:(NSDictionary *)parameter completionHandler:(void (^)(id responseObject))completionHandler {
  
  if (parameter == nil) {
    return;
  }
  NSString *data = [parameter objectForKey:@"data"];
  if (data && [data length] > 0){
    if ([data rangeOfString:@"cat_id"].location != NSNotFound && ([data rangeOfString:@"yulorepage-list:"]).location == NSNotFound) {
      
      __block  CategoryItem *aCategoryItem = nil;
      NSString *categoryID = [self catidWithData: [parameter objectForKey:@"data"]];
      
      
      [self.categoryDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        id tempCategoryID = obj[@"id"];
        if ([tempCategoryID isKindOfClass:[NSNumber class]]) {
          if ([[NSString stringWithFormat:@"%@", tempCategoryID] isEqualToString:categoryID]) {
            aCategoryItem = [[CategoryItem alloc] initWithDictionary:obj];
            *stop = YES;
          }
        }
        else {
          if ([tempCategoryID isEqualToString:categoryID]) {
            aCategoryItem = [[CategoryItem alloc] initWithDictionary:obj];
            *stop = YES;
          }
        }

        
      }];
      
      completionHandler(aCategoryItem);
    }
    else if ([data rangeOfString:@"yulorepage-list:"].location != NSNotFound) {
      __block  NearbyItem *aNearbyItem = nil;
      NSString *nearbyItemID = [self catidWithData: [parameter objectForKey:@"data"]];

      [self.nearbyDataValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([nearbyItemID isEqualToString: [self catidWithData:[obj valueForKeyPath:@"act.data"] ]]) {
          
          *stop = YES;
          aNearbyItem = [[NearbyItem alloc] initWithDictionary:obj];
          
        }

      }];
      
//      [self.allNearby enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        
//        aNearbyItem = (NearbyItem *)obj;
//        if ([nearbyItemID isEqualToString: [self catidWithData: aNearbyItem.nearbyAction]]) {
//          
//          *stop = YES;
//        
//        }
//      }];
      
      if (aNearbyItem) {
         completionHandler(aNearbyItem);
      }
      else {
        DLog(@"push nearby error");
      }
     
    }
  }
  
  
  
}
@end
