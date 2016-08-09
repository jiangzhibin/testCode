//
//  DHBHotCategoryView.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/3/18.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryItem.h"
#import "ServicesItem.h"
#import "NearbyItem.h"
#import "PromotionItem.h"
#import "UserPathHelper.h"
@class DHBHotCategoryView;
@protocol DHBHotCategoryViewDelegate <NSObject>
- (NSMutableArray *)nearbyItemsForHotCategoryView;
- (NSMutableArray *)categoriesItemsForHotCategoryView;
- (NSMutableArray *)servicesItemsForHotCategoryView;
- (NSMutableArray *)localServicesItemsForHotCategoryView;
- (NSMutableArray *)promotionsItemsForHotCategoryView;
- (NSMutableArray *)userPathItemsForHotCategoryView;

- (void)didSelectNearbyButtonAction;
- (void)selectServices:(ServicesItem *)aService type:(MainViewItemsType)type;
- (void)selectNearbyInfo:(NearbyItem *)aService;
- (void)selectHotCategory:(CategoryItem *)aCategory;
- (void)selectPromotionItem:(PromotionItem *)aPromotionItem;

@end

typedef void (^UserPathCompletionHandler)(UserPathItem *aUserPathItem);
@interface DHBHotCategoryView : UIScrollView
+ (DHBHotCategoryView *)sharedHotCategoryView;
@property (nonatomic, assign) id<DHBHotCategoryViewDelegate> categoryDelegate;
@property (nonatomic, copy) UserPathCompletionHandler userPathCompletionHandler;
@property (nonatomic, strong) NSMutableArray *categoriesItems;

- (void)reloadHotCategoryView;
- (void)reloadUserPathView;
- (void)selectUserItem:(NSString *)text completionHandler:(UserPathCompletionHandler)completionHandler;


@end
