//
//  CategoryButton.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 14/9/17.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ServicesItem;
@class CategoryItem;
@interface CategoryButton : UIButton
- (instancetype)initWithService:(ServicesItem *)aService;
- (instancetype)initWithCategory:(CategoryItem *)aCategory;
@end
