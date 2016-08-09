//
//  City.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-23.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "City.h"
#import "APIDotDianHuaDotCNClient.h"
#import "CommonTmp.h"
@implementation City
#pragma mark NSCopying



- (id)copyWithZone:(NSZone *)zone {
  City* copy = [[[self class]allocWithZone:zone]init];
  
  
  
  
  
 // copy.selected = [_selected copyWithZone:zone];
  copy.cityID = [_cityID copyWithZone:zone];
  copy.cityName = [_cityName copyWithZone:zone];
  copy.dataVersion = [_dataVersion copyWithZone:zone];
  copy.p_id = [_p_id copyWithZone:zone];
  copy.lastUpdate = [_lastUpdate copyWithZone:zone];
  copy.hot = [_hot copyWithZone:zone];
  copy.pinyinFull = [_pinyinFull copyWithZone:zone];
  copy.pinyinSimple = [_pinyinSimple copyWithZone:zone];
  copy.package = [_package copyWithZone:zone];
//  copy.preSaveDataPath = [_preSaveDataPath copyWithZone:zone];
//  copy.canUpdate =  _canUpdate;
  return copy;
}
#pragma mark  NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
//  [aCoder encodeObject:_selected forKey:@"selected"];
  [aCoder encodeObject:_cityID forKey:@"cityID"];
  [aCoder encodeObject:_cityName forKey:@"cityName"];
  [aCoder encodeObject:_dataVersion forKey:@"dataVersion"];
  [aCoder encodeObject:_p_id forKey:@"p_id"];
  [aCoder encodeObject:_lastUpdate forKey:@"lastUpdate"];
  [aCoder encodeObject:_hot forKey:@"hot"];
  [aCoder encodeObject:_pinyinFull forKey:@"pinyinFull"];
  [aCoder encodeObject:_pinyinSimple forKey:@"pinyinSimple"];
  [aCoder encodeObject:_package forKey:@"package"];
 // [aCoder encodeObject:_preSaveDataPath forKey:@"preSaveDataPath"];
  
 // [aCoder encodeBool:_canUpdate forKey:@"canUpdate"];
}



- (id)initWithCoder:(NSCoder *)aDecoder {
  
  //_selected = [aDecoder decodeObjectForKey:@"selected"];
  _cityID = [aDecoder decodeObjectForKey:@"cityID"];
  _cityName = [aDecoder decodeObjectForKey:@"cityName"];
  _dataVersion = [aDecoder decodeObjectForKey:@"dataVersion"];
  _p_id = [aDecoder decodeObjectForKey:@"p_id"];
  _lastUpdate = [aDecoder decodeObjectForKey:@"lastUpdate"];
  _hot = [aDecoder decodeObjectForKey:@"hot"];
  _pinyinFull = [aDecoder decodeObjectForKey:@"pinyinFull"];
  _pinyinSimple = [aDecoder decodeObjectForKey:@"pinyinSimple"];
  _package = [aDecoder decodeObjectForKey:@"package"];
//  _preSaveDataPath = [aDecoder decodeObjectForKey:@"preSaveDataPath"];
 // _canUpdate = [aDecoder decodeBoolForKey:@"canUpdate"];
  return self;
}

+ (NSMutableDictionary *)cityForNSDictionary:(City *)aCity {
  NSMutableDictionary *aCityDic = [[NSMutableDictionary alloc] init];
  
  [aCityDic setValue:aCity.cityID forKey:@"id"];
  [aCityDic setValue:aCity.cityName forKey:@"name"];
  [aCityDic setValue:aCity.dataVersion forKey:@"ver"];
  [aCityDic setValue:aCity.p_id forKey:@"pid"];
  // [aCityDic setValue:aCity forKey:@"id"];
  [aCityDic setValue:aCity.hot forKey:@"hot"];
  [aCityDic setValue:aCity.pinyinFull forKey:@"pyf"];
  [aCityDic setValue:aCity.pinyinSimple forKey:@"pys"];
  
  return aCityDic;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary {
  self = [super init];
  if (self) {
    _cityID = [aDictionary valueForKey:@"id"];
    _cityName = [aDictionary valueForKey:@"name"];
    _dataVersion = [aDictionary valueForKey:@"ver"];//[item valueForKey:@"id"];
    _p_id = [aDictionary valueForKey:@"pid"];
    _lastUpdate = nil;//[item valueForKey:@"id"];
    _hot =  [aDictionary valueForKey:@"hot"];
    _pinyinFull = [aDictionary valueForKey:@"pyf"];
    _pinyinSimple = [aDictionary valueForKey:@"pys"];
    _package = [aDictionary valueForKey:@"pkg"];
    _packageSize = [aDictionary valueForKey:@"size"];
   // _preSaveDataPath = [CityHelper preDataPath:self.cityID];
   // _canUpdate = NO;
    
  }
  return self;
}



+ (NSNumber *)localCurrentOfflineDataVersion {
  NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
  
  NSNumber *dataVersion = [pref objectForKey:@"LOCALOFFLINEDATA"];
  
  if (dataVersion == nil) {
    dataVersion = [NSNumber numberWithInt:0];
  }
  
  return dataVersion;
}


+ (BOOL)updateOfflineData:(NSDictionary *)offlineDic {
  BOOL update = NO;
  if (offlineDic) {
    NSNumber *latestVersion = [NSNumber numberWithInteger:[offlineDic[@"pkg_ver"] integerValue] ];
    NSNumber *localCurrentOfflineDataVersion = [self localCurrentOfflineDataVersion];
    if (localCurrentOfflineDataVersion < latestVersion) {
      update = YES;
    }
    
  }
  
  
  
  if (update) {
    DLog(@"post");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCurrentOfflineData"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:offlineDic
                                                                                           forKey:@"offlineDic"]];
  }
  
  return update;
}
@end
