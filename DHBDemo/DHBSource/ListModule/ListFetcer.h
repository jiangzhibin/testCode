//
//  ListFetcer.h
//  DianHuaBan
//
//  Created by Zhang Heyin on 13-7-17.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CategoryItem;

@interface ListFetcer : NSObject
+ (void)executeFectcerWithCategoryItem:(CategoryItem *)categoryItem
                                 block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block;


+ (BOOL)isJsonHasCategory:(CategoryItem *)categoryItem ;

+ (void)executeFectcerWithInformation3:(NSMutableDictionary *)information
                                 block:(void (^)( NSMutableArray *shopItems__, NSError *error) )block;
+ (NSMutableArray *)executeFectcerWithInformation2:(NSString *)information;
+ (NSMutableArray *)executeFectcerFromCategoryJson:(CategoryItem *)categoryItem;
+ (NSMutableArray *)executeFectcerWithInformation:(NSMutableDictionary *)information;
@end
