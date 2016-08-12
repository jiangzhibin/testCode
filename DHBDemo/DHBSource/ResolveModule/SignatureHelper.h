//
//  SignatureHelper.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-17.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
  SIGNATURETYPELIST,
  SIGNATURETYPEDETIAL,
  SIGNATURETYPECATEGORY
} SIGNATURETYPE;
@interface SignatureHelper : NSObject
+ (NSString *) listSignature:(NSMutableDictionary *)info;
+ (NSString *) batchResolveSignature:(NSString *)telenumberString;
+ (NSString *) resolveSignature:(NSString *)telenumber;
+ (NSString *) signatureWithDictionary:(NSDictionary *)info;
+ (NSString *) flagSignature:(NSString *)telenumber withFlag:(NSString *)flag withAppname:(NSString *)appName;
+ (NSString *) detialSignature:(NSDictionary *)info;

+ (NSString *)orderSignature:(NSString *)parametersString;
+ (NSString *)returnSignature:(NSString *)parametersString;
@end