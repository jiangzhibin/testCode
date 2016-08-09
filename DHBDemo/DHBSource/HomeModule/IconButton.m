//
//  IconButton.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-19.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//
#import "CommonTmp.h"
#import "IconButton.h"
#import "ListFetcer.h"
#import "StartLoadingService.h"
@interface IconButton()
@property (nonatomic, strong) UILabel *lable;
//@property (nonatomic, strong) CategoryItem *currentCategory;
@end
@implementation IconButton

//@synthesize currentCategory = _currentCategory;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIImage*) grayscale:(UIImage*)anImage type:(char)type {
  CGImageRef  imageRef;
  imageRef = anImage.CGImage;
  
  size_t width  = CGImageGetWidth(imageRef);
  size_t height = CGImageGetHeight(imageRef);
  
  // ピクセルを構成するRGB各要素が何ビットで構成されている
  size_t                  bitsPerComponent;
  bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
  
  // ピクセル全体は何ビットで構成されているか
  size_t                  bitsPerPixel;
  bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
  
  // 画像の横1ライン分のデータが、何バイトで構成されているか
  size_t                  bytesPerRow;
  bytesPerRow = CGImageGetBytesPerRow(imageRef);
  
  // 画像の色空間
  CGColorSpaceRef         colorSpace;
  colorSpace = CGImageGetColorSpace(imageRef);
  
  // 画像のBitmap情報
  CGBitmapInfo            bitmapInfo;
  bitmapInfo = CGImageGetBitmapInfo(imageRef);
  
  // 画像がピクセル間の補完をしているか
  bool                    shouldInterpolate;
  shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
  
  // 表示装置によって補正をしているか
  CGColorRenderingIntent  intent;
  intent = CGImageGetRenderingIntent(imageRef);
  
  // 画像のデータプロバイダを取得する
  CGDataProviderRef   dataProvider;
  dataProvider = CGImageGetDataProvider(imageRef);
  
  // データプロバイダから画像のbitmap生データ取得
  CFDataRef   data;
  UInt8*      buffer;
  data = CGDataProviderCopyData(dataProvider);
  buffer = (UInt8*)CFDataGetBytePtr(data);
  
  // 1ピクセルずつ画像を処理
  NSUInteger  x, y;
  for (y = 0; y < height; y++) {
    for (x = 0; x < width; x++) {
      UInt8*  tmp;
      tmp = buffer + y * bytesPerRow + x * 4; // RGBAの4つ値をもっているので、1ピクセルごとに*4してずらす
      
      // RGB値を取得
      UInt8 red,green,blue;
      red = *(tmp + 0);
      green = *(tmp + 1);
      blue = *(tmp + 2);
      
      UInt8 brightness;
      
      switch (type) {
        case 1://モノクロ
          // 輝度計算
          brightness = (77 * red + 28 * green + 151 * blue) / 256;
          
          *(tmp + 0) = brightness;
          *(tmp + 1) = brightness;
          *(tmp + 2) = brightness;
          break;
          
        case 2://セピア
          *(tmp + 0) = red;
          *(tmp + 1) = green * 0.7;
          *(tmp + 2) = blue * 0.4;
          break;
          
        case 3://色反転
          *(tmp + 0) = 255 - red;
          *(tmp + 1) = 255 - green;
          *(tmp + 2) = 255 - blue;
          break;
          
        default:
          *(tmp + 0) = red;
          *(tmp + 1) = green;
          *(tmp + 2) = blue;
          break;
      }
      
    }
  }
  
  // 効果を与えたデータ生成
  CFDataRef   effectedData;
  effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
  
  // 効果を与えたデータプロバイダを生成
  CGDataProviderRef   effectedDataProvider;
  effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
  
  // 画像を生成
  CGImageRef  effectedCgImage;
  UIImage*    effectedImage;
  effectedCgImage = CGImageCreate(
                                  width, height,
                                  bitsPerComponent, bitsPerPixel, bytesPerRow,
                                  colorSpace, bitmapInfo, effectedDataProvider,
                                  NULL, shouldInterpolate, intent);
  effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
  
  // データの解放
  CGImageRelease(effectedCgImage);
  CFRelease(effectedDataProvider);
  CFRelease(effectedData);
  CFRelease(data);
  
  return effectedImage;
}

- (UIImage *)imageWithNearbyIconURL:(NSString *)url {
  NSArray *array  = [url componentsSeparatedByString:@"/"];
  NSString *iconFileName = [array lastObject];
  NSString *pathForServiceIcon = [NSString pathForOfflineDataDirectory];
  
  NSString *string = [NSString stringWithFormat:@"%@%@", pathForServiceIcon, iconFileName];
  NSData *data = [NSData dataWithContentsOfFile:string];
  
  UIImage *image= nil;
  if (data) {
    UIImage *image = [UIImage imageWithData:data];
    return image;
  }
  
 image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
  
  if (!image) {
    data= [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/service_default.png",pathForServiceIcon]];
  }
//  UIImage *image = [UIImage imageWithData:data];
  return image;
}

- (UIImage *)imageWithServiceIconURL:(NSString *)url {
  NSArray *array  = [url componentsSeparatedByString:@"/"];
  NSString *iconFileName = [array lastObject];
  NSString *pathForServiceIcon = [NSString pathForOfflineDataDirectory];
  
  NSString *string = [NSString stringWithFormat:@"%@sicon_%@", pathForServiceIcon, iconFileName];
  NSData *data = [NSData dataWithContentsOfFile:string];
  if (!data) {
    data= [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/service_default.png",pathForServiceIcon]];
  }
  
  UIImage *image = [UIImage imageWithData:data];

  return image;
}

- (UIImage *)imageWithCategoryIconURL:(NSString *)url {
  NSArray *array  = [url componentsSeparatedByString:@"/"];
  NSString *iconFileName = [array lastObject];
  NSString *pathForServiceIcon = [NSString pathForOfflineDataDirectory];
  
  NSString *string = [NSString stringWithFormat:@"%@hicon_%@", pathForServiceIcon, iconFileName];
  NSData *data = [NSData dataWithContentsOfFile:string];
  if (!data) {
    data= [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/service_default.png",pathForServiceIcon]];
  }
  UIImage *image = [UIImage imageWithData:data];
  return image;
}




- (id)initWithCategory:(CategoryItem *)aCategory {
  
  CGFloat serviceItemTubeWidth = (kScreenWidth - 25) / 4.f;
  
  self = [self initWithFrame:CGRectMake(0, 0, serviceItemTubeWidth + 10, 48)];
  //self.currentCategory = aCategory;
  self.tag = [aCategory.categoryID intValue];
  //  [self addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];

  
  self.lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 45+17, serviceItemTubeWidth, 35)];
  
  [self.lable setBackgroundColor:[UIColor clearColor]];
  
  NSString *title = aCategory.categoryItem;
  if ([aCategory.categoryItem rangeOfString:@"本地"].location != NSNotFound) {
    title = [aCategory.categoryItem stringByReplacingOccurrencesOfString:@"本地" withString:@""];
  }
  
  
  self.lable.text = title;
  self.lable.textColor = UIColorFromRGB(0x1d2329);
  self.lable.font = [UIFont systemFontOfSize:12];
  self.lable.textAlignment = NSTextAlignmentCenter;
 // DLog(@"%@",[NSString stringWithFormat:@"iconButton.m - category hot_icon_%@  %@", aCategory.categoryID , aCategory.categoryItem]);
  
  [self setImage:[self imageWithCategoryIconURL:aCategory.iconURLString] forState:UIControlStateNormal];
  self.imageEdgeInsets = UIEdgeInsetsMake(15, 16, 37, 16);

  
  [self addSubview:self.lable];
  
  return self;
}

- (id)initWithNearByItem:(NearbyItem *)aNearByItem {
  CGFloat nearByItemTubeWidth = ([UIScreen mainScreen].bounds.size.width - 15) / 5.f;
  
  
  self = [self initWithFrame:CGRectMake(0, 0, nearByItemTubeWidth, 54)];
//  self.tag = [aService.servicesID intValue];
  _lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 34+10, nearByItemTubeWidth , 14)];
  
//  [_lable setBackgroundColor:[UIColor lightGrayColor]];
  
  NSString *title = aNearByItem.nearbyItemName;
  _lable.text = title;
  _lable.textColor = UIColorFromRGB(0x1d2329);
  _lable.font = [UIFont systemFontOfSize:13];
  //[self.lable setBackgroundColor:[UIColor grayColor]];
  _lable.textAlignment = NSTextAlignmentCenter;
  // [self setBackgroundColor:[UIColor concreteColor]];
  
//  [self setImage:[UIImage imageWithColor:[UIColor yellowColor]] forState:UIControlStateNormal];
  
  
  // DLog(@"%@",[NSString stringWithFormat:@"iconButton.m - service hot_icon_%@ %@", aService.servicesID, aService.title]);
  
  [self setImage:[self imageWithNearbyIconURL:aNearByItem.iconURLString] forState:UIControlStateNormal];
  
  CGFloat exInset = 1;
  if ([UIScreen mainScreen].bounds.size.width <= 320) {
    exInset = 6;
  }
  CGFloat leftAndRightInset = (nearByItemTubeWidth - 30) / 2;
  self.imageEdgeInsets = UIEdgeInsetsMake(0, leftAndRightInset, leftAndRightInset + exInset, leftAndRightInset);
  
  [self addSubview:_lable];
  
  
  return self;
}


- (id)initWithService:(ServicesItem *)aService {
  CGFloat serviceItemTubeWidth = ([UIScreen mainScreen].bounds.size.width - 30) / 4.f;
  
  
  self = [self initWithFrame:CGRectMake(0, 0, serviceItemTubeWidth, serviceItemTubeWidth)];
  self.tag = [aService.servicesID intValue];
  self.lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 45 + 7, serviceItemTubeWidth, 14)];
  
  [self.lable setBackgroundColor:[UIColor whiteColor]];
  
  NSString *title = aService.title;
  self.lable.text = title;
  self.lable.textColor = UIColorFromRGB(0x1d2329);
  self.lable.font = [UIFont systemFontOfSize:13];
  //[self.lable setBackgroundColor:[UIColor grayColor]];
  self.lable.textAlignment = NSTextAlignmentCenter;
// [self setBackgroundColor:[UIColor concreteColor]];
  
 // DLog(@"%@",[NSString stringWithFormat:@"iconButton.m - service hot_icon_%@ %@", aService.servicesID, aService.title]);
//  [self setImage: [UIImage imageWithColor:[UIColor belizeHoleColor]] forState:UIControlStateNormal];
  [self setImage:[self imageWithServiceIconURL:aService.iconURLString] forState:UIControlStateNormal];
  
//  self.imageView.backgroundColor = [UIColor wetAsphaltColor];
  
  CGFloat leftAndRightInset = (serviceItemTubeWidth - 45) / 2;
  self.imageEdgeInsets = UIEdgeInsetsMake(0, leftAndRightInset, leftAndRightInset * 2, leftAndRightInset);
  
    [self addSubview:self.lable];
  
//  self.backgroundColor = [UIColor wisteriaColor];
  return self;
}
//
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//  DLog(@"drawRect:(CGRect)rect");
//}
//

@end
