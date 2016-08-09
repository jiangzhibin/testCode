//
//  UserPathHelper.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/7/29.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalSettings.h"
@class UserPathItem;

typedef void (^AddUserPathCompletionHandler)(BOOL addUserPathScuess);

@interface UserPathHelper : NSObject
- (NSMutableArray *)allUserPathItems;
+ (UserPathHelper *)sharedUserPathHelper;
- (void)userPathAction:(UserPathItem *)aUserPathItem
     completionHandler:(AddUserPathCompletionHandler)completionHandler;

@end

//typedef NS_ENUM(NSInteger, DHBUserPathItemType) {
//  DHBUserPathItemTypeCategory,
//  DHBUserPathItemTypeLocalService,
//  DHBUserPathItemTypeService,
//  DHBUserPathItemTypeNearBy
////  DHBUserPathItemType
//};


@interface UserPathItem : NSObject <NSCoding>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, assign) MainViewItemsType type;
+ (instancetype)userPathItemWith:(id)userActionItem type:(MainViewItemsType)type;
+ (instancetype)userPathItemWith:(id)userActionItem;
@end
