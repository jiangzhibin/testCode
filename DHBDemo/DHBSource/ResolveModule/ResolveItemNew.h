//
//  ResolveItem.h
//  TestMuti1
//
//  Created by Zhang Heyin on 15/3/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 号码查询结果中 标签类型
typedef NS_ENUM(NSInteger, DHBMarkNumberType) {
    DHBMarkNumberTypeUnMark         =-1,//未能反查
    DHBMarkNumberTypeAdvertising        = 0,//广告推销
    DHBMarkNumberTypeHarassing          = 1,//骚扰电话
    DHBMarkNumberTypeSuspectedFraud     = 2,//疑似诈骗
    DHBMarkNumberTypeExpress            = 3,//快递送餐
    DHBMarkNumberTypeIntermediary       = 4,//房产中介
    DHBMarkNumberTypeRoomService        = 5,//外卖送餐
    DHBMarkNumberTypeInsuranceMarketing = 6,//保险推销
    DHBMarkNumberTypeUserDefine         = 7,//保险推销
    
};

@interface ResolveItemNew : NSObject <NSCoding>
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *rank;
@property (nonatomic, copy) NSString *rDescription;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageLink;
@property (nonatomic, copy) NSString *rID;
@property (nonatomic, copy) NSString *rType;
@property (nonatomic, copy) NSString *teleNumber;
@property (nonatomic, copy) NSString *logoImageLink;
@property (nonatomic, copy) NSString *highrisk;

@property (nonatomic, copy) NSString *flagNumber;
@property (nonatomic, copy) NSString *flagType;
@property (nonatomic, copy) NSString *flagDate;

@property (nonatomic, copy) NSString *displayTitle;
@property (nonatomic, copy) NSString *flagInfo;
@property (nonatomic, copy) NSString *shopID;
@property (nonatomic, copy) NSMutableArray *teleNumbers;
@property (nonatomic, copy) NSString *webURL;

@property (nonatomic, copy) NSString *sloganImageURL;
@property (nonatomic, copy) NSString *sloganContent;

@property (nonatomic, copy) NSString *userFlagContent;
@property (nonatomic, assign) DHBMarkNumberType userTaggedType;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
