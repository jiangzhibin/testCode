//
//  ResolveFecher.h
//  TestMuti1
//
//  Created by Zhang Heyin on 15/3/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolveItemNew.h"
@interface ResolveFecherNew : NSObject
+ (instancetype)sharedResolveFecherNew;

- (void)resolveFectcherWithTelephoneNumber:(NSString *)telephoneNumber completionHandler:(void (^)( ResolveItemNew *resolveItem, NSError *error) )completionHandler;
+ (BOOL)canResolveNumber:(NSString *)telenumber error:(NSError **)error;
@end
