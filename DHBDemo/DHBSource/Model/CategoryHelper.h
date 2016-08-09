//
//  CategoryHelper.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 14/9/15.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryHelper : NSObject
+ (instancetype)sharedCategoryHelper;
- (void)allCategoryDictionaryWithblock:(void (^)(NSMutableDictionary *allCategoryDictionary, NSError *error))block;
- (void)finalBlock:(void (^)( NSDictionary * result))block;

@property (nonatomic, strong) NSMutableArray *allLocalServicesArray;
@property (nonatomic, strong) NSMutableArray *allServicesArray;
@property (nonatomic, strong) NSArray *allCategories;
@property (nonatomic, strong) NSMutableArray *allHotCategories;

@end
