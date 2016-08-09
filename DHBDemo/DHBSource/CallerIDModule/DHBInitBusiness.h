//
//  DHBInitBusiness.h
//  CallerID
//
//  Created by Zhang Heyin on 15/8/12.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHBUpdateItem.h"
@interface DHBInitBusiness : NSObject
+ (BOOL)dhbInitBusiness;
+ (NSString *)dateFormatStringSetuped;
+ (NSString *)dateStringSetuped;
+ (void)setupInitDate;
+ (void)updateCurrentVersionWithItem:(DHBUpdateItem *)item;
@end
