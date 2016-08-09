//
//  OfflineDataHelper.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-23.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class City;
#define chinese @"chinese"
#define pinyin @"pinyin"
#define pinyinindex @"pinyinindex"
#define pinyinshort @"pinyinshort"
#define pinyinshortindex @"pinyinshortindex"
#define dataoffset @"offset"
#define datalength @"length"
typedef enum DATAFILETYPE {
  DataPinyin,
  DataCategory,
  DataCategoryDat,
  DataDetail
	
} DataFileType;
@interface OfflineDataHelper : NSObject
+ (BOOL)hasCategoryData;
+ (BOOL)canOfflineSearch;
+ (NSString *)nationaldataFilePath:(DataFileType)type;
+ (NSArray *)pinyinIndexWithKeyWords:(NSString *)keyWords;
//+ (NSMutableArray *)pinyinIndexFileOffsetArray;
//+ (NSMutableArray *)allItem;
+ (BOOL)decompressDatFile:(City *)aCity;
+ (NSData *)dataOfFilePath:(DataFileType)type;
+ (NSString *)dataFilePath:(DataFileType)type;
//+ (BOOL)deleteSelected:(City *)aCity ;
//+ (BOOL)deleteSelectedCityID:(NSInteger)aCity;
//+ (BOOL) updateCityDataDelete :(City *)aCity;
//+ (BOOL) updateCityDataDeleteWithCityID :(NSInteger)aCity;
@end
