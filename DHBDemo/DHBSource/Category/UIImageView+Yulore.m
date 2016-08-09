//
//  UIImageView+Yulore.m
//  yellowpage
//
//  Created by Zhang Heyin on 15/11/2.
//  Copyright © 2015年 Yulore. All rights reserved.
//

#import "UIImageView+Yulore.h"
#import "UIImageView+AFNetworking.h"
#import "Commondef.h"
#import "NSString+YuloreFilePath.h"
@implementation UIImageView (Yulore)


- (void)setImageWithShopID:(NSString *)shopID withURL:(NSURL *)URL {
  
  UIImage *imageData = [UIImage imageWithContentsOfFile:[NSString pathForOfflineLOGOWithShopID:shopID]];
  
  if (imageData) {
    self.image = imageData;
  } else {
    [self setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"list_icon_default"]];
  }
  
}


#pragma mark -
- (void)setImageWithCategoryURL:(NSString *)urlString {
  NSArray *array  = [urlString componentsSeparatedByString:@"/"];
  NSString *iconFileName = [array lastObject];
  NSString *pathForServiceIcon = [NSString pathForOfflineDataDirectory];
  
  NSString *string = [NSString stringWithFormat:@"%@%@", pathForServiceIcon, iconFileName];
  NSData *imageData = [NSData dataWithContentsOfFile:string];
  UIImage *placeholderImage = [UIImage imageWithData:imageData];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  
  
  
  
  
  __weak __typeof(self)weakSelf = self;
  
  [self setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    __strong __typeof(weakSelf)strongSelf = weakSelf;
    //    DLog(@"setImageWithURLRequest %@" , request.URL);
    strongSelf.image = image;
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    
  }];
  
  //
  //
  //  if (imageData) {
  //    self.image = [UIImage imageWithData:imageData];
  //  } else {
  //    [self setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"list_icon_default"]];
  //  }
  
}

@end
