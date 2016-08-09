//
//  City.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-23.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject<NSCoding, NSCopying>
+ (NSMutableDictionary *)cityForNSDictionary:(City *)aCity;
- (id)initWithDictionary:(NSDictionary *)aDictionary;
//@property (nonatomic, strong) NSString *selected;
@property (nonatomic, copy) NSString *cityID;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *dataVersion;
//@property (nonatomic, assign) BOOL canUpdate;
@property (nonatomic, copy) NSString *p_id;
@property (nonatomic, copy) NSString *lastUpdate;
@property (nonatomic, copy) NSString *hot;
@property (nonatomic, copy) NSString *pinyinFull;
@property (nonatomic, copy) NSString *pinyinSimple;
@property (nonatomic, copy) NSString *package;
//@property (nonatomic, strong) NSString *preSaveDataPath;
@property (nonatomic, copy) NSString *packageSize;
//@property (nonatomic, assign) BOOL downloading;
//+ (void)globalCitesWithBlock:(void (^)( NSMutableArray *cities, NSError *error))block;
@end
