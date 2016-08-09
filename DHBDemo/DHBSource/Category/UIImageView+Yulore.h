//
//  UIImageView+Yulore.h
//  yellowpage
//
//  Created by Zhang Heyin on 15/11/2.
//  Copyright © 2015年 Yulore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Yulore)
- (void)setImageWithCategoryURL:(NSString *)urlString;
- (void)setImageWithShopID:(NSString *)shopID withURL:(NSURL *)URL;
@end
