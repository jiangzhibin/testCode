//
//  Commondef.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/5.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#ifndef Commondef_h
#define Commondef_h

#ifdef __OBJC__

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#define kERRORTYPE          @"errortype"
#define kVERSION            @"version"
#define kCITY_ID            @"city_id"
#define kSEARCHCATEGORY     @"t"
#define kCAT_ID             @"cat_id"
#define kSTART              @"s"
#define kNUMBER             @"n"
#define kQUERY              @"q"
#define kUID                @"uid"
#define kMN                 @"mn"
#define kLAT                @"lat"
#define kLNG                @"lng"
#define kOLDER              @"o"
#define kSID                @"sid"
#define kDIS_ID             @"dis_id"
#define kSIGNATURE          @"sig"


#endif /* #ifdef __OBJC__ */
#endif  /* #ifndef Commondef_h */
