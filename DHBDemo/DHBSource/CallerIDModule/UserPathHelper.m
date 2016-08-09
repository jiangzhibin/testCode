//
//  UserPathHelper.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/7/29.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "UserPathHelper.h"
#import "CommonTmp.h"
static  NSString* kFileName = @"UserPath";
@interface UserPathHelper()
@property (nonatomic, strong) NSMutableArray *userPathList;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *filenamePath;

@end

@implementation UserPathHelper
- (NSMutableArray *)allUserPathItems {
  return self.userPathList;
}
- (void)userPathAction:(UserPathItem *)aUserPathItem completionHandler:(AddUserPathCompletionHandler)completionHandler {
  
  
//  if ([self checkThisUserPath:aUserPathItem]) {
//    [self removeUserPathWithShopItem:aUserPathItem completionHandler:^(BOOL addUserPathScuess) {
//      completionHandler(YES);
//    }];
//  }
//  else {
    [self addUserPath:aUserPathItem completionHandler:^(BOOL addUserPathScuess) {
      completionHandler(YES);
    }];
//  }

  BOOL sucess = NO;
  sucess = [NSKeyedArchiver archiveRootObject:self.userPathList toFile:self.filenamePath];
  completionHandler(sucess);
  
}
- (NSInteger)indexInUserPath:(UserPathItem *)aUserPathItem {
  __block NSInteger index = -1;
  [self.userPathList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UserPathItem *tempShopItem = (UserPathItem *)obj;
    if ([aUserPathItem.itemID isEqualToString:tempShopItem.itemID]) {
      
      index = idx;
    }
  }];
  
  return index;
}

- (BOOL) checkThisUserPath:(UserPathItem *)aUserPathItem {
  
  
  NSInteger index = [self indexInUserPath:aUserPathItem];
  
  
  return (index == -1) ? NO : YES;
}



+ (UserPathHelper *)sharedUserPathHelper {
  static UserPathHelper *_sharedUserPathHelper = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedUserPathHelper = [[UserPathHelper alloc] init];
  });
  
  return _sharedUserPathHelper;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _userPathList = [self loadCurrentUserPathList];
    
    if (!_userPathList) {
      _userPathList = [[NSMutableArray alloc] init];
    }
    
  }
  
  return self;
}

- (NSString *)filePath {
  
  if (!_filePath) {
    _filePath = [NSString pathForUserPathHelperCachesDirectory];
    
  }
  return _filePath;
}

- (NSString *)filenamePath {
  if (!_filenamePath) {
    _filenamePath = [self.filePath stringByAppendingPathComponent:kFileName];
  }
  
  return _filenamePath;
}

- (NSMutableArray *)loadCurrentUserPathList {
  
  NSMutableArray *userPathList = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filenamePath];
		
  return userPathList;
}

- (void) removeUserPathWithShopItem:(UserPathItem *)aUserPathItem completionHandler:(AddUserPathCompletionHandler)completionHandler {
  NSInteger index = -1;
  if ((index = [self indexInUserPath:aUserPathItem]) != -1) {
    
    [self.userPathList removeObjectAtIndex:index];
    
  }
  
  
  BOOL sucess = NO;
  sucess = [NSKeyedArchiver archiveRootObject:self.userPathList toFile:self.filenamePath];
  completionHandler(sucess);
  
}
- (void)updateAndAdd:(UserPathItem *)aShopItemNeedAdd {
  
  
  [self removeUserPathWithShopItem:aShopItemNeedAdd completionHandler:^(BOOL addUserPathScuess) {
    [self.userPathList insertObject:aShopItemNeedAdd atIndex:0];
    
    if ([self.userPathList count] > 5) {
      [self.userPathList removeLastObject];
    }
    
  }];
  
  
}

- (BOOL)addUserPath:(UserPathItem *)aUserPathItem completionHandler:(AddUserPathCompletionHandler)completionHandler {
  
  
  [self updateAndAdd:aUserPathItem];
  NSError *error = nil;
  // 确定存储路径，一般是Document目录下的文件
  
  
  if (![[NSFileManager defaultManager] createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:&error]) {
    DLog(@"创建用户文件目录失败");
    return NO;
  }
  // return NO;
  // return [NSKeyedArchiver archiveRootObject:self toFile:[fileName:userId]];
  BOOL sucess = NO;
  sucess = [NSKeyedArchiver archiveRootObject:self.userPathList toFile:self.filenamePath];
  completionHandler(sucess);
  
  
  return sucess;
}
@end

#import "CategoryItem.h"
#import "ServicesItem.h"
#import "NearbyItem.h"
@implementation UserPathItem


+ (instancetype)userPathItemWith:(id)userActionItem type:(MainViewItemsType)type {
  
  UserPathItem *aUserPathItem = [[UserPathItem alloc] init];
      aUserPathItem.type = type;
  switch (type) {
    case MainViewItemsTypeCommonService:
      aUserPathItem.title = ((ServicesItem *)userActionItem).title;
      aUserPathItem.itemID = ((ServicesItem *)userActionItem).servicesID;
      break;
      
    case MainViewItemsTypeCategory:
      aUserPathItem.title = ((CategoryItem *)userActionItem).categoryItem;
      aUserPathItem.itemID = ((CategoryItem *)userActionItem).categoryID;
      break;
      
    case MainViewItemsTypeLocalService:
      aUserPathItem.title = ((ServicesItem *)userActionItem).title;
      aUserPathItem.itemID = ((ServicesItem *)userActionItem).servicesID;
      break;
      
      
    case MainViewItemsTypeNeaby:
      aUserPathItem.title  = [NSString stringWithFormat:@"附近%@", ((NearbyItem *)userActionItem).nearbyItemName];
      aUserPathItem.itemID = ((NearbyItem *)userActionItem).nearbyItemID;
      break;
  }
  
  return aUserPathItem;
  
}



+ (instancetype)userPathItemWith:(id)userActionItem {
  
  UserPathItem *aUserPathItem = [[UserPathItem alloc] init];
  if ([userActionItem isKindOfClass:[CategoryItem class]]) {
    aUserPathItem.type = MainViewItemsTypeCategory;
    aUserPathItem.title = ((CategoryItem *)userActionItem).categoryItem;
    aUserPathItem.itemID = ((CategoryItem *)userActionItem).categoryID;
  }
  else if ([userActionItem isKindOfClass:[ServicesItem class]]) {
    aUserPathItem.type = MainViewItemsTypeCommonService;
    aUserPathItem.title = ((ServicesItem *)userActionItem).title;
    aUserPathItem.itemID = ((ServicesItem *)userActionItem).servicesID;
  }
  
  return aUserPathItem;
}



- (id)initWithCoder:(NSCoder *)aDecoder {
  
  if ((self = [super init])){
    if ([aDecoder containsValueForKey:@"TYPE"]) {
      _type =   [aDecoder decodeIntForKey:@"TYPE"];
    }
    if ([aDecoder containsValueForKey:@"ID"]) {
      _itemID =   [aDecoder decodeObjectForKey:@"ID"];
    }
    if ([aDecoder containsValueForKey:@"TITLE"]) {
      _title =   [aDecoder decodeObjectForKey:@"TITLE"];
    }
    
  }
  return self;
  
}


- (void)encodeWithCoder:(NSCoder*)coder {
  [coder encodeInteger:_type forKey:@"TYPE"];
  [coder encodeObject:_itemID forKey:@"ID"];
  [coder encodeObject:_title forKey:@"TITLE"];

}
@end
