//
//  CityHelper.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-25.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class City;
@interface CityHelper : NSObject
@property (nonatomic, strong) NSMutableDictionary *cityDictionary;
@property (nonatomic, strong) NSMutableDictionary *provinceDictionary;
@property (nonatomic, strong) NSMutableDictionary *areacodeDictionary;

//+ (NSMutableArray *)allProvinces;

+ (instancetype)sharedCityHelper;

//+ (NSString *)nameWithCityID:(NSString *)cityID andWithProvincesID:(NSString *)ProvinceID;
//+ (NSString *)preDataPath:(NSString *)aCity;
+ (void) selectCurrentCity:(City *)aCity;
+ (void) SetLocationCurrentCity:(City *)aCity;
+ (NSString *)selectedCity ;
+ (NSMutableArray *)allCityNative;
+ (NSMutableArray *)allCity:(NSArray *)nativeArray;
+ (NSArray *)cityPinyinIndex:(NSMutableArray *)cityArray;
+ (NSMutableDictionary *)cityIndexDictionary:(NSArray *)cityIndexArray
                                   cityArray:(NSMutableArray *)cityArray;
+ (NSMutableArray *)hotCity:(NSMutableArray *)allCitys;
+ (NSMutableArray *)cityArrayWithNative:(NSArray *)nativeArray;
+ (NSString *)selectedCityName;
//+ (NSMutableArray *)checkAllUpdateCities;

//+ (NSMutableArray *)allSelectCities;
//+ (NSMutableArray *)allSelectCitiesWithAllList:(NSMutableArray *)allList;
//+ (BOOL)removeZipFile:(City *)aCity;
//+ (BOOL) updateCitySelect:(City *)aCity;
//+ (void)unZipWithZipCity:(City *)aCity;
+ (City *)currentLocationCity;
@end
