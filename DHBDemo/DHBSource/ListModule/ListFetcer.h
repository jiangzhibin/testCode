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

+ (BOOL)isJsonHasCategory:(CategoryItem *)categoryItem ;

+ (NSMutableArray *)executeFectcerFromCategoryJson:(CategoryItem *)categoryItem;
@end
