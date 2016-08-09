//
//  DHBSDKConfiguration.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/8.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKConfiguration.h"
#define kCityIdKey      @"cityId"

@implementation DHBSDKConfiguration

+ (instancetype)shareInstance {
    static DHBSDKConfiguration *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DHBSDKConfiguration new];
    });
    return instance;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityId forKey:kCityIdKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.cityId = [aDecoder decodeObjectForKey:kCityIdKey];
    }
    return self;
}
@end
