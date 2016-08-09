//
//  CategoryButton.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 14/9/17.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "CategoryButton.h"
#import "UIImageView+Yulore.h"
#import "CategoryItem.h"
#import "ServicesItem.h"
#import "GlobalMacros.h"
@interface CategoryButton()
@end
@implementation CategoryButton

- (id)initWithService:(ServicesItem *)aService{
  
  
  self = [self initWithFrame:CGRectMake(0, 0, 147, 50)];
  if (self) {
    
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [ UIFont systemFontOfSize:14];
    [self setTitle: aService.title
          forState:UIControlStateNormal];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(-10, [self space], 10, 0)];
    [self setTitleColor:UIColorFromRGB(0x202020) forState:UIControlStateNormal];
    
    [self addSubview:[self subTitleViewWithItem:aService]];
    [self addSubview:[self categoryImageViewWithItem:aService]];
    
  }
  return  self;
  
  
}
- (CGFloat)space {
  CGFloat space = kScreenWidth / 6.f;
  return space;
}


- (UILabel *)subTitleViewWithItem:(id)item {
  NSString *subName = nil;
  if ([item isKindOfClass:[CategoryItem class]]) {
    subName = ((CategoryItem *)item).categorySubName;
  }
  else if ([item isKindOfClass:[ServicesItem class]]) {
    subName = ((ServicesItem *)item).subTitle;
  }
  
  UILabel *labelView = [[UILabel alloc] init];
  labelView.frame = CGRectMake([self space], 25, kScreenWidth / 2 -56, 16);
  labelView.backgroundColor = [UIColor clearColor];
  labelView.font = [UIFont systemFontOfSize:12];
  labelView.textColor = UIColorFromRGB(0x74757e);
  labelView.text = subName;
  return labelView;
}
- (UIImageView *)categoryImageViewWithItem:(id)item {
  NSString *urlString = nil;
  if ([item isKindOfClass:[CategoryItem class]]) {
    urlString = ((CategoryItem *)item).iconURLString;
  }
  else if ([item isKindOfClass:[ServicesItem class]]) {
    urlString = ((ServicesItem *)item).iconURLString;
  }
  
  
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([self space] / 2.f - 15, 10, 30, 30)];
//  imageView.backgroundColor = [UIColor yellowColor];
  [imageView setImageWithCategoryURL:urlString];
  return imageView;
}


- (id)initWithCategory:(CategoryItem *)aCategory {
  
  
  self = [self initWithFrame:CGRectMake(0, 0, 147, 50)];
  if (self) {
    
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [ UIFont systemFontOfSize:14];
    [self setTitle: aCategory.categoryItem forState:UIControlStateNormal];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(-10, [self space], 10, 0)];
    [self setTitleColor:UIColorFromRGB(0x202020) forState:UIControlStateNormal];
    
    
    [self addSubview:[self subTitleViewWithItem:aCategory]];
    [self addSubview:[self categoryImageViewWithItem:aCategory]];
  }
  return  self;
  
  
}
@end
