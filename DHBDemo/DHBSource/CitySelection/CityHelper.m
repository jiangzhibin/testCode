//
//  CityHelper.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-25.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "CityHelper.h"
#import "City.h"

#import "CommonTmp.h"
#import "Commondef.h"

@implementation CityHelper


SINGLETON_GCD(CityHelper);



- (instancetype)init {
  self = [super init];
  
  if (self) {

    
    NSMutableArray *allCityNative = [[CityHelper cityArrayFromFile] valueForKey:@"cities"];
    NSMutableDictionary *cityDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *areacodeDict = [NSMutableDictionary dictionary];
    [allCityNative enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [cityDict setObject:obj forKey:obj[@"id"]];
      [areacodeDict setObject:obj forKey:obj[@"areacode"]];

    }];
    
    NSMutableArray *allProvincesNative = [[CityHelper cityArrayFromFile] valueForKey:@"provinces"];
    NSMutableDictionary *provinceDict = [NSMutableDictionary dictionary];
    [allProvincesNative enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [provinceDict   setObject:obj forKey:obj[@"id"]];
      
    }];
    
    
    
    _cityDictionary = cityDict;
    _provinceDictionary = provinceDict;
    _areacodeDictionary = areacodeDict;
       // DLog(@"CityHelper  CityHelper");
    
  }
  
  
  return  self;
}
+ (NSString *)preDataPath:(NSString *)aCityID {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];
  //dbPath： 数据库路径，在Document中。
  NSString *folderPath = [documentDirectory stringByAppendingPathComponent:@"temp"];
	//创建文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//判断temp文件夹是否存在
	BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
	
	if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
		[fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
  
  
  
  NSString *dbPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",aCityID]];
  return dbPath;
}
+ (NSString *)cityDataFilePath {
  
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory,NSUserDomainMask, YES);
  NSString *cacheDirectory = [paths objectAtIndex:0];
  NSString *cacheDirectoryFolderPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Caches/OfflineData/city.json"]];
  
  
  return cacheDirectoryFolderPath;
}

+ (NSDictionary *)cityArrayFromFile {
  NSData *jsonData = [NSData dataWithContentsOfFile:[self cityDataFilePath]];
  NSError *error = nil;
  NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
  if (error) DLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
  
  return results;
}

//
//+ (NSMutableArray *)checkAllUpdateCities {
//  NSInteger canUpdate = 0;
//  NSMutableArray *allUpdateCity = [NSMutableArray array];
//  NSMutableArray *allSelectCities = [self allSelectCities];
//  NSMutableArray *allCityNative = [[self cityArrayFromFile] valueForKey:@"cities"];
//  if ([allSelectCities count] > 0) {
//    for (City *aCity in allSelectCities) {
//      for (NSMutableDictionary *dic in allCityNative) {
//        if ([[dic objectForKey:@"id"] isEqualToString:aCity.cityID]) {
//          if ([aCity.dataVersion integerValue] < [[dic objectForKey:@"ver"] integerValue]) {
//            canUpdate++;
//            [allUpdateCity addObject:aCity];
//          }
//        }
//      }
//    }
//  }
//  return allUpdateCity;
//}


+ (NSArray *)sortedSearchArray:(NSMutableArray *)unsortedArray
                        forKey:(NSString *)forkey {
  NSArray *sortedArray = [unsortedArray sortedArrayUsingComparator:^(id obj1,id obj2) {
    NSDictionary *dic1 = (NSDictionary *)obj1;
    NSDictionary *dic2 = (NSDictionary *)obj2;
    NSNumber *num1 = (NSNumber *)[dic1 objectForKey:forkey];
    NSNumber *num2 = (NSNumber *)[dic2 objectForKey:forkey];
    if ([num1 floatValue] > [num2 floatValue]) {
      return (NSComparisonResult)NSOrderedDescending;
    } else {
      return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
  }];
  
  return sortedArray;
}

+ (NSMutableArray *)allCityNative {
  Reachability *reach = [Reachability reachabilityWithHostName:kHost];
  NSMutableArray *allCityNative = [[self cityArrayFromFile] valueForKey:@"cities"];
  if ([reach isReachable]) {
    // Reachable
    
    
    
    dispatch_queue_t q = dispatch_queue_create("queue", 0);
    dispatch_async(q, ^{
      
      NSString *query = [NSString stringWithFormat:@"%@city/?sig=%@&uid=%@&apikey=%@", @"0",kDIANHUACNURL, [OpenUDID value], [YuloreApiManager sharedYuloreApiManager].apiKey];
      query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      // DLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);
      NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
      NSArray *paths = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory,NSUserDomainMask, YES);
      NSString *cacheDirectory = [paths objectAtIndex:0];
      NSString *cacheDirectoryFolderPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Caches/OfflineData/city.json"]];
      [jsonData writeToFile:cacheDirectoryFolderPath atomically:YES];
      
    });
    // dispatch_release(q);
  } else {
    // Isn't reachable
    // allCityNative = [[self cityArrayFromFile] valueForKey:@"cities"];
  }
  
  
  
  return allCityNative;
}

+ (NSMutableArray *)cityArrayWithNative:(NSArray *)nativeArray {
  
  NSMutableArray *cityArray = [[NSMutableArray alloc] init];
  for (NSDictionary *aCityDic in nativeArray) {
    City *aCity = [[City alloc] initWithDictionary:aCityDic];
    [cityArray addObject:aCity];
  }
  
  return cityArray;
}
+ (NSMutableArray *)allCity:(NSMutableArray *)nativeArray {
  
  NSMutableArray *allCityArray = [[NSMutableArray alloc] init];
  for (NSDictionary *aCityDic in nativeArray) {
    City *aCity = [[City alloc] initWithDictionary:aCityDic];
    [allCityArray addObject:aCity];
  }
  
  return allCityArray;
}


+ (NSArray *)cityPinyinIndex:(NSMutableArray *)cityArray {
  
  NSMutableArray *indexArray = [[NSMutableArray alloc] init];
  for (City *aCity in cityArray) {
    NSString *index = [aCity.pinyinSimple substringToIndex:1];
    [indexArray addObject:index];
  }
  NSSet *pinyinSet = [[NSSet alloc] initWithArray:indexArray];
 // DLog(@"%@", pinyinSet);
  
  
  return pinyinSet.allObjects;
}


+ (NSMutableDictionary *)cityIndexDictionary:(NSArray *)cityIndexArray cityArray:(NSMutableArray *)cityArray{
  NSMutableDictionary *cityIndexDictionary = [[NSMutableDictionary alloc] init];
  
  for (NSString *pinyinIndex in cityIndexArray) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (City *aCity in cityArray) {
      if ([pinyinIndex isEqualToString:[aCity.pinyinSimple substringToIndex:1]]) {
        [array addObject:aCity];
      }
    }
    
    [cityIndexDictionary setObject:array forKey:pinyinIndex];
  }
  
  return cityIndexDictionary;
}



+ (NSMutableArray *)hotCity:(NSMutableArray *)allCitys {
  NSMutableArray *hotCity = [[NSMutableArray alloc] init];
  for (City *aCity in allCitys) {
    if ([[NSString stringWithFormat:@"%@",aCity.hot ] isEqualToString:@"1"]) {
      [hotCity addObject:aCity];
    }
  }
  return hotCity;
}


+ (void) selectCurrentCity:(City *)aCity {
  NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
  [pref setObject:aCity.cityID forKey:@"City"];
  [pref setObject:aCity.cityName  forKey:@"CityName"];
  [pref synchronize];
}
+ (void) SetLocationCurrentCity:(City *)aCity {
  NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
  [pref setObject:aCity.cityID forKey:@"LocationCity"];
  [pref setObject:aCity.cityName  forKey:@"LocationCityName"];
  [pref synchronize];
}



+ (City *)currentLocationCity {
  NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];

    NSString *city = [pref objectForKey:@"LocationCityName"];
    NSString *cityID = [pref objectForKey:@"LocationCity"];
  if (cityID == nil) {
    return nil;
  }
  City *aCity = [[City alloc] init];
  aCity.cityName = city;
  aCity.cityID = cityID;
  return aCity;
}




+ (NSString *)selectedCityName {
  NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
  
  NSString *city = [pref objectForKey:@"CityName"];
  
  if (city == nil) {
    city = @"未定义";
  }
  
  return city;
}
+ (NSString *)selectedCity {
  NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
  
  NSString *cityID = [pref objectForKey:@"City"];
  if (!cityID) {
    cityID = @"0";
  }
  return cityID;
}





//
//
//+ (NSString *)databasePath {
//  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//  NSString *documentDirectory = [paths objectAtIndex:0];
//  //dbPath： 数据库路径，在Document中。
//  NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"yulore.db"];
//  return dbPath;
//}
//
//+ (NSString *)downloadTime {
//  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//  //设定时间格式,这里可以设置成自己需要的格式
//  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//  //用[NSDate date]可以获取系统当前时间
//  NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
//  return currentDateStr;
//}
//
//+ (BOOL) updateCitySelect:(City *)aCity {
//  //创建数据库实例 db  这里说明下:如果路径中不存在"Test.db"的文件,sqlite会自动创建"Test.db"
//  FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
//  BOOL result = NO;
//  if (![db open]) {
//    DLog(@"Could not open db.");
//    return NO;
//  } else {
//    
//    NSString *SQLUPDATE = [NSString stringWithFormat:@"UPDATE city SET selected=%@,dataversion = %@,lastUpdate='%@' WHERE c_id=%@",aCity.downloading ? @"2":@"1", aCity.dataVersion, [self downloadTime],aCity.cityID];
//    result = [db executeUpdate:SQLUPDATE];
//  }
//  // [db close];
//  return result;
//}

//
//+ (NSMutableArray *)allSelectCities {
//  NSMutableArray *allSelectCities = [[NSMutableArray alloc] init];
//  FMDatabase *db= [FMDatabase databaseWithPath:[self databasePath]];
//  
//  if (![db open]) {
//    DLog(@"Could not open db.");
//    return nil;
//  } else {
//    NSString *SQLQUERY = [NSString stringWithFormat:@"SELECT * from city"];
//    FMResultSet *rs = [db executeQuery:SQLQUERY];
//    
//    while ([rs next]) {
//      int selectd = [rs intForColumn:@"selected"];
//      if (selectd == 1 || selectd == 2) {
//        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//        [dic setValue:[rs stringForColumn:@"c_id"] forKey:@"id"];
//        [dic setValue:[rs stringForColumn:@"c_name"] forKey:@"name"];
//        [dic setValue:[rs stringForColumn:@"dataVersion"] forKey:@"ver"];
//        
//        City *aCity = [[City alloc] initWithDictionary:dic];
//        
//        aCity.downloading = selectd == 1 ? NO : YES;
//        [allSelectCities addObject:aCity];
//        
//        
//      }
//    }
//    [rs close];
//  }
//  
//  return allSelectCities;
//}
//
//+ (NSMutableArray *)allSelectCitiesWithAllList:(NSMutableArray *)allList{
//  NSMutableArray *allSelectCities = [self allSelectCities];
//  for (City *aCity in allSelectCities) {
//    for (NSMutableDictionary *dic in allList) {
//      
//      if ([[dic objectForKey:@"id"] isEqualToString:aCity.cityID]) {
//        aCity.packageSize = [dic objectForKey:@"size"];
//        aCity.canUpdate = [aCity.dataVersion integerValue] < [[dic objectForKey:@"ver"] integerValue] ? @"1" : @"0";
//        break;
//      }
//    }
//    
//    
//  }
//  return allSelectCities;
//}

//
//+ (BOOL) updateCityDataVersion:(int)newVersion cityID:(NSString *)cityID {
//  //创建数据库实例 db  这里说明下:如果路径中不存在"Test.db"的文件,sqlite会自动创建"Test.db"
//  FMDatabase *db= [FMDatabase databaseWithPath:[self databasePath]];
//  BOOL result = NO;
//  if (![db open]) {
//    DLog(@"Could not open db.");
//    return NO;
//  } else {
//    NSString *SQLUPDATE = [NSString stringWithFormat:@"UPDATE City SET DataVersion=%d,LastUpdate=datetime('now','localtime') WHERE CityID=%@", newVersion, cityID];
//    result = [db executeUpdate:SQLUPDATE];
//  }
//  //[db close];
//  return result;
//}
//+ (BOOL)removeZipFile:(City *)aCity {
//  NSString *zipFilePath = aCity.preSaveDataPath;
//  NSFileManager *fileManager = [NSFileManager defaultManager];
//  
//  return [fileManager removeItemAtPath:zipFilePath error:nil];
//}
//
//+ (void)unZipWithZipCity:(City *)aCity {
//	
//	//MBProgressHUD *mbp = [MBProgressHUD showHUDAddedTo:self animated:YES];
//	//mbp.labelText = @"   解压中,请等待...   ";
//	//初始化Documents路径
//  NSArray *paths = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory,NSUserDomainMask, YES);
//  NSString *documentsDirectory = [paths objectAtIndex:0];
//  
//  
//	//NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//	//设置ZIP文件路径
//	NSString *zipFilePath = aCity.preSaveDataPath;	//设置解压文件夹的路径
//	NSString *unZipPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Caches"]];
//	//初始化ZipArchive
//	YuloreZipArchive *zip = [[YuloreZipArchive alloc] init];
//	
//	BOOL result;
//	
//	if ([zip UnzipOpenFile:zipFilePath]) {
//		
//		result = [zip UnzipFileTo:unZipPath overWrite:YES];//解压文件
//		if (!result) {
//			//解压失败
//			DLog(@"unzip fail................");
//		}else {
//			//解压成功
//			DLog(@"unzip success.............");
//      [self removeZipFile:aCity];
//      //NSFileManager *fileManager = [NSFileManager defaultManager];
//      
//      //[fileManager removeItemAtPath:zipFilePath error:nil];
//			//因为文件小,解压太快,为了更好的看到效果,故添加了一个3秒之后执行的取消"菊花"操作.
//      //	[self performSelector:@selector(threeClick) withObject:nil afterDelay:3];
//		}
//    
//		[zip UnzipCloseFile];//关闭
//	}
//}




@end
