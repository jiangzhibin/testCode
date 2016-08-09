//
//  IconButton.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-19.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CategoryItem.h"
#import "ServicesItem.h"
#import "NearbyItem.h"
@interface IconButton : UIButton
- (id)initWithCategory:(CategoryItem *)aCategory;
- (id)initWithService:(ServicesItem *)aService;
- (id)initWithNearByItem:(NearbyItem *)aNearByItem;
@end
