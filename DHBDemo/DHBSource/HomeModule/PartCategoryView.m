//
//  PartCategoryView.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/6/1.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "PartCategoryView.h"

@implementation PartCategoryView
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
  }
  
  return self;
}


- (void)drawRect:(CGRect)rect {
  
  int time = rect.size.height - 30 / 50 + 1;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat inset = 0.5 / [[UIScreen mainScreen] scale];
  
  float COLOR = 0xD9/255.f;
  CGContextSetLineWidth(context, inset*2);
  /*NO.1画一条线*/
  for (int i = 0; i < time; i++) {
    CGContextSetRGBStrokeColor(context, COLOR, COLOR, COLOR, 1);//线条颜色
    CGContextMoveToPoint(context, 0, inset  + 50 + 30 + i * 50);
    CGContextAddLineToPoint(context,  rect.size.width,inset + 50 + 30 + i * 50);
    CGContextStrokePath(context);
    
  }
  
  
  CGContextSetRGBStrokeColor(context, COLOR, COLOR, COLOR, 1);//线条颜色
  CGContextMoveToPoint(context, rect.size.width / 2.f +  inset , 30);
  CGContextAddLineToPoint(context, rect.size.width / 2.f+inset , rect.size.height);
  CGContextStrokePath(context);
  
}
@end
