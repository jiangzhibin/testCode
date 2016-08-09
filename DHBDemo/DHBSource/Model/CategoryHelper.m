//
//  CategoryHelper.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 14/9/15.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "CategoryHelper.h"
#import "APIDotDianHuaDotCNClient.h"
#import "CategoryItem.h"
#import "ServicesItem.h"
#import "Commondef.h"
#import "CommonTmp.h"
@interface CategoryHelper()
@property (nonatomic, copy) NSDictionary *categoryAPIDictionary;
@property (nonatomic, copy) NSArray *categoriesArray;
@property (nonatomic, copy) NSMutableDictionary *allCategoryDictionary;




@end
@implementation CategoryHelper

SINGLETON_GCD(CategoryHelper);



- (id) init {
  self = [super init];
  if (self) {
//    [self updateCategoryDataFromServerWithBlock:^(NSDictionary *result) {
//
//      _categoryAPIDictionary = result;
//    } internetBlock:^(NSDictionary *result) {
//      DLog(@"block  ----   Internet !");
//      _categoryAPIDictionary = result;
//    }];
    [self finalBlock:^(NSDictionary *result) {
      [self updateData];
      DLog(@"   finalBlock  %ld", (unsigned long)[_allCategories count]);
      

    }];
  }
  return self;
}


- (NSArray *)categoriesArray {
  NSArray *array = _categoriesArray;
  if (_categoriesArray == nil) {
    array = [self arrayDataFromFile:@"category"];
    _categoriesArray = array;
  }
  return array;
  
}

- (NSMutableDictionary *)allCategoryDictionary {
  NSMutableDictionary *dictionary = _allCategoryDictionary;
  if (_allCategoryDictionary == nil) {
    dictionary = [self rebuildCategoryDictionaryWitchArray:self.categoriesArray];
    _allCategoryDictionary = dictionary;
  }
  return dictionary;
}




- (NSDictionary *)dictionaryDataFromFile {
  NSData *arrayData  = [NSData dataWithContentsOfFile:[NSString pathForCategoryDataFileWithCityID:[YuloreApiManager sharedYuloreApiManager].cityId]];
  if ([arrayData length] < 1024) {
    arrayData  = [NSData dataWithContentsOfFile:[NSString pathForOriginalCategoryDataFile]];
  }
  
  NSError *error = nil;
  NSDictionary *results = arrayData ? [NSJSONSerialization JSONObjectWithData:arrayData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
  
  
  return results;
}
- (NSArray *)arrayDataFromFile:(NSString *)key {
  NSData *arrayData  = [NSData dataWithContentsOfFile:[NSString pathForCategoryDataFileWithCityID:[YuloreApiManager sharedYuloreApiManager].cityId]];
  if ([arrayData length] < 1024) {
    arrayData  = [NSData dataWithContentsOfFile:[NSString pathForOriginalCategoryDataFile]];
  }
  
  NSError *error = nil;
  NSDictionary *results = arrayData ? [NSJSONSerialization JSONObjectWithData:arrayData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
  NSArray *array =  [NSArray array];//[results valueForKey:@"category"];
  if (!error) {
    array = [results valueForKey:key];
  }
  else {
    array = nil;
  }
  return array;
}

- (NSMutableDictionary *)rebuildCategoryDictionaryWitchArray:(NSArray *)categories {
  NSMutableDictionary *rebuildCategory = [[NSMutableDictionary alloc] init];
  for (NSDictionary *aCategory in categories) {
    
    if (aCategory) {
      [rebuildCategory setObject:aCategory forKey:aCategory[@"id"]];
    }
  }
  return rebuildCategory;
}

- (void)finalBlock:(void (^)( NSDictionary * result))block {
  [self updateCategoryDataFromServerWithBlock:^(NSDictionary *result) {
    block(result);
       DLog(@"block  ----   Memory !");
    _categoryAPIDictionary = result;
  } internetBlock:^(NSDictionary *result) {
    block(result);
    _categoryAPIDictionary = result;
       DLog(@"block  ----   Internet !");
  }];
}


- (void)updateData {
  self.allCategories = [self  arrayDataFromFile:@"category"];
  self.allHotCategories = [self allHotCategories];
  
  
  
  
  NSArray * serviceArray = [self arrayDataFromFile:@"services"];
  
  self.allServicesArray = [self rebuildServices:serviceArray];
  
  NSArray * serviceLocalArray = [self arrayDataFromFile:@"localsvcs"];
  

  self.allLocalServicesArray = [self rebuildLocalServices:serviceLocalArray];
  
  
  
}


- (NSMutableArray *)rebuildServices:(NSArray *)serviceArray {
  NSMutableArray *allServices = [[NSMutableArray alloc] init];
  for (NSDictionary *aService in serviceArray) {
    ServicesItem *aServiceItem = [[ServicesItem alloc] initWithDictionary:aService];
    [allServices addObject:aServiceItem];
  }
  
  
  return allServices;
}


- (NSMutableArray *)rebuildLocalServices:(NSArray *)serviceArray {
  NSMutableArray *allLocalServices = [[NSMutableArray alloc] init];
  for (NSDictionary *aService in serviceArray) {
    ServicesItem *aServiceItem = [[ServicesItem alloc] initWithDictionary:aService];
    
    
    [allLocalServices addObject:aServiceItem];
  }
  
  
  return allLocalServices;
}


- (NSMutableArray *)allHotCategorys {
  NSMutableArray *hotCategorys = [[NSMutableArray alloc] init];
  //NSMutableArray *mainArray = [self.rebuildCategory valueForKeyPath:@"0"];
  
  for (NSDictionary *aCategoryItemDic in self.allCategories) {

    if (([aCategoryItemDic[@"hot"] intValue]) == 1 ) {
      CategoryItem *aCategoryItem = [[CategoryItem alloc] initWithDictionary:aCategoryItemDic];
      [hotCategorys addObject:aCategoryItem];
    }
    
  }
  return hotCategorys;
}





- (void)updateCategoryDataFromServerWithBlock:(void (^)( NSDictionary * result))memoryBlock
                                internetBlock:(void (^)( NSDictionary * result))internetBlock {
  memoryBlock([self dictionaryDataFromFile]);
  
  Reachability *reach = [Reachability reachabilityWithHostName:kHost];
  if ([reach isReachable]) {
    
      NSString *cityID = [YuloreApiManager sharedYuloreApiManager].cityId;
    if (cityID == nil) {
      // memoryBlock([self dictionaryDataFromFile]);
    }
    else {
      
      NSString * uid = [OpenUDID value];
      

      // [client setDefaultHeader:@"Accept" value:@"application/json"];
      // [client setAuthorizationHeaderWithUsername:self.username password:self.password];
      NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
        NSString *query = [NSString stringWithFormat:@"%@category/?city_id=%@&uid=%@&ver=%@&apikey=%@",kDIANHUACNURL, cityID, uid, ver,[YuloreApiManager sharedYuloreApiManager].apiKey];
//      //NSString *query = [NSString stringWithFormat:@"category/?city_id=%@&uid=%@", cityID, uid];
//      NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:query parameters:nil];
//      [request setTimeoutInterval:5];
      
      [[APIDotDianHuaDotCNClient sharedClient] GET:query parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

        if (responseObject) {
          if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            
            
            
            NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];//[NSKeyedArchiver
            //做一下持久化
            if (jsonData) {
              NSString *dataName = [NSString stringWithFormat:@"/Caches/OfflineData/category%@.dat", cityID];
              
              NSArray *paths = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory,NSUserDomainMask, YES);
              NSString *cacheDirectory = [paths objectAtIndex:0];
              //dbPath： 数据库路径，在Document中。
              NSString *filePath = [cacheDirectory stringByAppendingPathComponent:dataName];
              // DLog(@"dataName %@", dataName);
              [jsonData writeToFile:filePath atomically:YES];
            }
            //
            internetBlock(responseObject);
            
          }
        }
      } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
      }];
      
    }
  }
  
}



- (void)allCategoryDictionaryWithblock:(void (^)(NSMutableDictionary *allCategoryDictionary, NSError *error))block {
  if (self.allCategoryDictionary != nil) {
    block(_allCategoryDictionary, nil);
  }
  else {
    block(nil, nil);
  }
  
}

@end

