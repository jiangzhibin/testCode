//
//  DHBInitBusiness.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/12.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "DHBInitBusiness.h"
#import "NSString+YuloreFilePath.h"
#import "DHBCovertIndexContent.h"
#import "FileHash.h"
@implementation DHBInitBusiness
+ (void)updateCurrentVersionWithItem:(DHBUpdateItem *)item; {
  NSString *deltaString =  [[item.fullDownloadPath   lastPathComponent] stringByDeletingPathExtension];
  
  NSArray *fileNameArray = [deltaString componentsSeparatedByString:@"_"];
  NSString *versionString = [fileNameArray lastObject];
  
  NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
  
  [pref setValue:versionString forKey:@"InitDate"];
  
  [pref synchronize];
}

+ (void)setupInitDate {
  
  NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
  
  NSString *setupDate = (NSString *)[pref valueForKey:@"InitDate"];
  
  if (setupDate) {
    return;
  }
  NSString *data = @"0";
  
  
  [pref setValue:data forKey:@"InitDate"];
  
  [pref synchronize];
}

+ (NSString *)dateStringSetuped {
  NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
  
  NSString *setupDate = (NSString *)[pref valueForKey:@"InitDate"];
  
  return setupDate;
}

+ (NSDate *)dateWithSetuped {
  NSString *dateString = [self dateStringSetuped];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
  [dateFormatter setDateFormat:@"yyyyMMdd"];
  NSDate *aDate = [dateFormatter dateFromString:dateString];
  
  
  return aDate;
}

+ (NSString *)dateFormatStringSetuped {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [NSLocale currentLocale];
  
  NSString *showtimeNew = [NSDateFormatter localizedStringFromDate:[self dateWithSetuped]
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterNoStyle];
  
  return showtimeNew;
}

/**
 *  复制文件到沙箱
 */
+ (BOOL)copyDataFile {
  //  BOOL result = NO;
  NSString *dataFolderPath = [[NSBundle mainBundle] pathForResource:@"data.dat" ofType:nil];
  NSData *dataBundleFile = [NSData dataWithContentsOfFile:dataFolderPath];
  
  BOOL created =  [[NSFileManager defaultManager] createFileAtPath:[NSString pathForFullOfflineFilePath]
                                                          contents:dataBundleFile
                                                        attributes:nil];
  
  return created;
}

+ (BOOL)needCopyDataFile {
  
  BOOL result = YES;
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString pathForFullOfflineFilePath]]) {
    
    
    return NO;
  
//    NSString *dataFolderPath = [[NSBundle mainBundle] pathForResource:@"data.dat" ofType:nil];
//    
//    NSString *bundleFileMD5 = [FileHash md5HashOfFileAtPath:dataFolderPath];
//    
//    NSString *sandboxFileMD5 = [FileHash md5HashOfFileAtPath:[NSString pathForFullOfflineFilePath]];
//    
//    //bundel中的数据文件的md5跟沙箱中的一样，不需要更新
//    BOOL equal = [sandboxFileMD5 isEqualToString:bundleFileMD5];
//    
//    result = !equal;
  }
  else {
    result = YES;
  }
  
  return result;
}

+ (BOOL)dhbInitBusiness {
  
  [self setupInitDate];
  
  BOOL result = YES;
  
  if ([self needCopyDataFile]) {
    
    result = [self copyDataFile];
    
  }
  
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
  [dateFormatter setDateFormat:@"yyyyMMdd"];
  NSDate *aDate = [dateFormatter dateFromString:@"20150822"];
  
  
  
  NSString *showtimeNew = [NSDateFormatter localizedStringFromDate:aDate
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterNoStyle];
  

  [DHBCovertIndexContent sharedInstance];
  
  return result;
}

@end
