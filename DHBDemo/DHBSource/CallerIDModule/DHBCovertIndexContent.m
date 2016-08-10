//
//  DHBCovertIndexContent.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/12.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//
#import <CallKit/CallKit.h>
#import "DHBCovertIndexContent.h"
#import "ListFetcer.h"
#import "TeleNumber.h"
#import "ShopItem.h"
#import "CommonTmp.h"
#import "CategoryFetcer.h"

@interface DHBCovertIndexContent()
@property (nonatomic, strong) NSDate *dataVersionDate;

@property (nonatomic, assign) NSInteger currentVersion;
@end

@implementation DHBCovertIndexContent

//
- (NSString *)dataFileInfo {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  // [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  dateFormatter.locale = [NSLocale currentLocale];
  NSString *showtimeNew = [NSDateFormatter localizedStringFromDate:self.dataVersionDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
  NSString *displayInfo = [NSString stringWithFormat:@"Current Version: %@", showtimeNew];
  return displayInfo;
}

+ (instancetype)sharedInstance {
  static DHBCovertIndexContent *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[DHBCovertIndexContent alloc] init];
  });
  
  return _sharedInstance;
}

- (instancetype)init {
  self = [super init];
  
  if (self) {
    _resolveDataFile = [[ResolveDataFile alloc] init];
    _dataVersionDate = [NSDate dateWithTimeIntervalSince1970:_resolveDataFile.timeStamp];
    _currentVersion = _resolveDataFile.currentVersion;
    NSLog(@"init version %@ %ld", _dataVersionDate ,_currentVersion);
  }
  
  return self;
}

- (void)loadHotCategoryNumbersComplete:(void(^)(NSDictionary *hotTeleNumberList))completeBlock {
    [[CategoryFetcer sharedCategoryFetcer] categoriesWithCityID:[YuloreApiManager sharedYuloreApiManager].cityId loadFromSandboxCompletionHandler:^(NSMutableArray *allHotCategories, NSMutableArray *allServices, NSMutableArray *allLocalServices, NSMutableArray *allNeabys, NSMutableArray *allPromotions, NSError *error) {
        NSMutableArray *categoryItems = [NSMutableArray new];
        [categoryItems addObjectsFromArray:allHotCategories];
        [categoryItems addObjectsFromArray:allLocalServices];
        completeBlock([self getHotTelNumberListWithCategoryItems:categoryItems]);
    } updateFromServerCompletionHandler:^(NSMutableArray *allHotCategories, NSMutableArray *allServices, NSMutableArray *allLocalServices, NSMutableArray *allNeabys, NSMutableArray *allPromotions, NSError *error) {
        /*
        NSMutableArray *categoryItems = [NSMutableArray new];
        [categoryItems addObjectsFromArray:allHotCategories];
        [categoryItems addObjectsFromArray:allLocalServices];
        completeBlock([self getHotTelNumberListWithCategoryItems:categoryItems]);
         */
    }];

}

- (NSDictionary *)getHotTelNumberListWithCategoryItems:(NSArray *)categoryItems {
    NSMutableDictionary * hotTeleNumberList = [[NSMutableDictionary alloc] initWithCapacity:10000];
    for (CategoryItem * aCategoryItem in categoryItems) {
        //NSLog(@"Category Item: %@",aCategoryItem);
        NSMutableArray *shopItems__ =[ListFetcer executeFectcerFromCategoryJson:aCategoryItem];
        //[ListFetcer executeFectcerWithCategoryItem:aCategoryItem block:^(NSMutableArray *shopItems__, NSError *error) {
        DLog(@"test list item");
        
        if (shopItems__) {
            NSLog(@"Shop Item ****");
            for (id aShopItem in shopItems__) {
                NSLog(@"Shop Item ====");
                for (id shopItems in [aShopItem allValues]) {
                    NSLog(@"Shop Item ----");
                    for (id item in shopItems) {
                        if ([item isKindOfClass:[ShopItem class]]){
                            ShopItem * shopItem = item;
                            for (TeleNumber * tel in shopItem.teleNumbers) {
                                NSString * telNumber=[[NSString alloc] initWithString:[tel.teleNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                                NSString * label;
                                if ([tel.teleDescription isEqualToString:@"电话"]) {
                                    label = [[NSString alloc] initWithString:shopItem.name];
                                } else {
                                    label = [[NSString alloc] initWithFormat:@"%@ | %@",shopItem.name,tel.teleDescription];
                                }
                                if ([[telNumber substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"])
                                {
                                    [hotTeleNumberList setObject:label forKey:[[NSString alloc] initWithFormat:@"+86%@",[telNumber substringFromIndex:1]]];
                                } else {
                                    [hotTeleNumberList setObject:label forKey:[[NSString alloc] initWithFormat:@"+86%@",telNumber]];
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            
        }
        //}];
    }
    return hotTeleNumberList;
}

- (void)readDataFromFile:(void (^)(float progress))progressBlock
       completionHandler:(void (^)(NSError *error))completionHandler {
    NSLog(@"reload data in BG");
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        progressBlock(0.1f);
    });
    [_resolveDataFile readDataFromFile:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            progressBlock(0.1f+progress*0.6f);
        });
    }];
    [self saveDataToBridgeFile:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            progressBlock(0.7f+progress*0.29f);
        });
    }];
    
    NSLog(@"reload data in BG DONE");
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        completionHandler(nil);
    });
}

-(void) saveDataToBridgeFile:(void (^)(float progress))progressBlock {
    NSMutableDictionary * list=[_resolveDataFile resolveOffsetDictionary];
    NSString *filePath = [NSString pathForBridgeOfflineFilePath];
    NSLog(@"store resolve: %@",filePath);
    
    [self loadHotCategoryNumbersComplete:^(NSDictionary *hotList) {
        NSArray * hotListKeys=[hotList allKeys];
        for (NSString * key in hotListKeys){
            [list setObject:[hotList objectForKey:key] forKey:key];
            NSLog(@"HOT: %@ %@",key,[hotList objectForKey:key]);
        }
        //import hot category numbers
        
        for (int i=0;i<1000;i++) {
            @autoreleasepool {
                NSString * filePathI=[[NSString alloc] initWithFormat:@"%@%d",filePath,i];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePathI])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePathI error:nil];
                }
            }
        }
        
        int i=0;
        int SPLIT_SIZE=10000;
        NSString * filePathI=[[NSString alloc] initWithFormat:@"%@%ld",filePath,(long)(i/SPLIT_SIZE)];
        NSMutableDictionary * subList = [[NSMutableDictionary alloc] initWithCapacity:SPLIT_SIZE];
        NSArray * keys = [list allKeys];
        
        keys = [keys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        for (NSString * key in keys)
        {
            [subList setObject:[self tagLabelFromTagID:[list objectForKey:key]] forKey:key];
            
            if (i%SPLIT_SIZE==SPLIT_SIZE-1){
                NSLog(@"%@",key);
                [subList writeToFile:filePathI atomically:YES];
                //NSLog(@"store resolve %d: %@",i,filePathI);
                [subList removeAllObjects];
                filePathI=[[NSString alloc] initWithFormat:@"%@%ld",filePath,(long)((i+1)/SPLIT_SIZE)];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    progressBlock((float)i/(float)[keys count]);
                });
            }
            i++;
        }
        if ([[subList allKeys] count]>0){
            [subList writeToFile:filePathI atomically:YES];
            [subList removeAllObjects];
        }

    }];
}

-(NSString *) tagLabelFromTagID:(id)tagId {
    if ([tagId intValue]==1) {
        return @"骚扰电话";
    }
    else if ([tagId intValue]==2) {
        return @"推销";
    }
    else if ([tagId intValue]==3) {
        return @"中介";
    }
    else if ([tagId intValue]==4) {
        return @"快递送餐";
    }
    else if ([tagId intValue]==5) {
        return @"疑似诈骗";
    }
    else if ([tagId intValue]==6) {
        return @"招聘猎头";
    }
    else if ([tagId intValue]==7) {
        return @"出租车司机";
    }
    else {
        return tagId;
    }
}

- (void)needReload {
    _resolveDataFile = nil;
    _resolveDataFile = [[ResolveDataFile alloc] init];
    _dataVersionDate = [NSDate dateWithTimeIntervalSince1970:_resolveDataFile.timeStamp];
    NSLog(@"needReload version %@", _dataVersionDate );
}

- (NSData *)mappedData {
  _mappedData = [_resolveDataFile mappedData];
  
  return _mappedData;
}

- (NSDictionary *)indexContent {
  _indexContent = [_resolveDataFile resolveOffsetDictionary];
  
  return _indexContent;
}

@end
