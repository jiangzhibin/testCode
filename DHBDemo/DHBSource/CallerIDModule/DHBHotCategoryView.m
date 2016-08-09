//
//  DHBHotCategoryView.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/3/18.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//
#import "CommonTmp.h"
#import "DHBHotCategoryView.h"
#import "CategoryButton.h"
#import "CategoryItem.h"

#import "ServicesItem.h"
#import "PromotionItem.h"
#import "IconButton.h"
#import "PartCategoryView.h"
#import "SDCycleScrollView.h"
#import "YuloreApiManager.h"
#import "OpenUDID.h"
#import "NSString+YuloreFilePath.h"
#define kADRate 334.f/1080.f
#define kADViewHeigh kScreenWidth * kADRate
#define kServiceTitleHeigh 30.f
@interface DHBHotCategoryView () <UIScrollViewDelegate, SDCycleScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *servicesView;

@property (nonatomic, strong) UIView *nearByView;
@property (nonatomic, strong) UIView *userPathView;
@property (nonatomic, strong) PartCategoryView *categoryView;
@property (nonatomic, strong) NSMutableArray *userPathItems;
@property (nonatomic, strong) NSMutableArray *servicesItems;
@property (nonatomic, strong) NSMutableArray *localServicesItems;
@property (nonatomic, strong) NSMutableArray *nearbyItems;
@property (nonatomic, strong) NSMutableArray *promotionItems;
@property (nonatomic, strong) SDCycleScrollView *sdCycleScrollView;

@property (nonatomic, strong) NSMutableArray *userPathItemButtonArray;
@property (nonatomic, strong) NSMutableArray *userPathViewButtonsArray;



@property (nonatomic, strong) NSMutableArray *categoryItemButtonArray;
@property (nonatomic, strong) NSMutableArray *sevicesItemButtonArray;
@property (nonatomic, strong) NSMutableArray *nearbyItemButtonArray;
@property (nonatomic, strong) NSMutableArray *promotionItemButtonArray;


@property (nonatomic, strong) UIButton *centerButton;
@end



@implementation DHBHotCategoryView
+ (DHBHotCategoryView *)sharedHotCategoryView {
  static DHBHotCategoryView *_sharedHotCategoryView = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedHotCategoryView = [[DHBHotCategoryView alloc] init];
    //_sharedClient.parameterEncoding = AFJSONParameterEncoding;
  });
  
  return _sharedHotCategoryView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)reloadHotCategoryView {
  if ([_categoryDelegate respondsToSelector:@selector(categoriesItemsForHotCategoryView)]) {
    _categoriesItems = [_categoryDelegate categoriesItemsForHotCategoryView];
  }
  
  
  if ([_categoryDelegate respondsToSelector:@selector(servicesItemsForHotCategoryView)]) {
    _servicesItems = [_categoryDelegate servicesItemsForHotCategoryView];
  }
  
  if ([_categoryDelegate respondsToSelector:@selector(localServicesItemsForHotCategoryView)]) {
    _localServicesItems = [_categoryDelegate localServicesItemsForHotCategoryView];
  }
  if ([_categoryDelegate respondsToSelector:@selector(nearbyItemsForHotCategoryView)]) {
    _nearbyItems = [_categoryDelegate nearbyItemsForHotCategoryView];
  }
  
  if ([_categoryDelegate respondsToSelector:@selector(promotionsItemsForHotCategoryView)]) {
    _promotionItems = [_categoryDelegate promotionsItemsForHotCategoryView];
  }
  
  if ([_categoryDelegate respondsToSelector:@selector(userPathItemsForHotCategoryView)]) {
    _userPathItems = [_categoryDelegate userPathItemsForHotCategoryView];
  }
  
  
  [self beforeSetup];
  [self setup];
}

- (void)beforeSetup {
  [self.pageControl removeFromSuperview];
  [self.servicesView removeFromSuperview];
  [self.categoryView removeFromSuperview];
  [self.nearByView removeFromSuperview];
  [self.userPathView removeFromSuperview];
  [self.sdCycleScrollView removeFromSuperview];
  [_categoryItemButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *aView = obj;
    [aView removeFromSuperview];
  }];
  [_sevicesItemButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *aView = obj;
    [aView removeFromSuperview];
  }];
  [_nearbyItemButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *aView = obj;
    [aView removeFromSuperview];
  }];
  
  
  [_userPathItemButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *aView = obj;
    [aView removeFromSuperview];
  }];
  DLog(@"beforeSetup ------------------------------------- beforeSetup");
}


- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    [self reloadHotCategoryView];
  }
  
  return self;
}


- (IBAction)userPathItemAction:(UIButton *)sender {
  _userPathCompletionHandler([_userPathItems objectAtIndex:((NSUInteger)sender.tag)]);
}
- (void)selectUserItem:(NSString *)text completionHandler:(UserPathCompletionHandler)completionHandler {
  DLog(@"completionHandler:(UserPathCompletionHandler)completionHandler %@ ", _userPathCompletionHandler);
  //  if (!_userPathCompletionHandler) {
  self.userPathCompletionHandler = completionHandler;
  //}
  
}

- (void)reloadUserPathView {
  DLog(@"reload path view");
  
  
  if ([_userPathItems count] == 0) {
    [self reloadHotCategoryView];
  }
  else {
    _userPathItems = [[UserPathHelper sharedUserPathHelper] allUserPathItems];
    [_userPathViewButtonsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      UIView *aView = obj;
      [_userPathItemButtonArray removeObject:obj];
      [aView removeFromSuperview];
    }];
    
  }
  
  
  [self addUserPathButton];
}


- (void)addUserPathButton {
  UIButton *lastButton = nil;
  CGFloat xOffset = 90;
  NSInteger i = 0;
  
  for (UserPathItem *aUserPathItem in _userPathItems) {
    
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setTitle:aUserPathItem.title forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [aButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [aButton setTag:i];
    i++;
    [aButton addTarget:self action:@selector(userPathItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [aButton sizeToFit];
    CGSize buttonSize = [aButton frame].size;
    
    
    if (lastButton) {
      xOffset = xOffset + lastButton.frame.size.width;
    }
    aButton.frame = CGRectMake(xOffset, 0, buttonSize.width + 10, 50);
    
    if (xOffset + buttonSize.width + 10 > kScreenWidth) {
      continue;
    }
    
    
    [self.userPathView addSubview:aButton];
    lastButton = aButton;

    if (!_userPathViewButtonsArray) {
      _userPathViewButtonsArray = [[NSMutableArray alloc] init];
    }
    [_userPathViewButtonsArray addObject:aButton];
    
  }
  
}

-  (void)userPathViewWithOffset:(CGFloat)offset {
//  DLog(@"userPathViewWithOffset");
  self.userPathView.frame = CGRectMake(0, offset, kScreenWidth, 50);
  self.userPathView.backgroundColor = [UIColor whiteColor];
  
  UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.userPathView.frame.size.width, 50)];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 50)];
  titleLabel.text = @"我的足迹";
  titleLabel.font = [UIFont systemFontOfSize:14];
  titleLabel.textColor = UIColorFromRGB(0x0287d3);
  
  
  [self.userPathView addSubview:titleLabel];
  [self.userPathView addSubview:titleView];
  
  
  [self addUserPathButton];
  
  
  if (!_userPathItemButtonArray) {
    _userPathItemButtonArray = [[NSMutableArray alloc] init];
  }
  
  
  [_userPathItemButtonArray addObject:titleView];
  
  [_userPathItemButtonArray addObject:titleLabel];
  
  
  UIView *lineViewUp = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.userPathView.frame.size.width, 0.5)];
  lineViewUp.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [self.userPathView addSubview:lineViewUp];
  UIView *lineViewDown = [[UIView alloc] initWithFrame:CGRectMake(0, 50-0.5, self.userPathView.frame.size.width, 0.5)];
  lineViewDown.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [self.userPathView addSubview:lineViewDown];
  //  self.userPathView.backgroundColor = [UIColor blackColor];
  
  
  [_userPathItemButtonArray addObject:lineViewDown];
  [_userPathItemButtonArray addObject:lineViewUp];
  
  
  [self addSubview:self.userPathView];
}




-  (void)nearByViewWithOffset:(CGFloat)offset {
  self.nearByView.frame = CGRectMake(0, offset, kScreenWidth, 108);
  //  self.nearByView = [[UIView alloc] initWithFrame:CGRectMake(0, offset, self.frame.size.width, 108)];
  self.nearByView.backgroundColor = [UIColor whiteColor];
  //  self.nearByView.backgroundColor = [UIColor greenColor];
  UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.nearByView.frame.size.width, 30)];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
  titleLabel.text = @"我的附近";
  titleLabel.font = [UIFont systemFontOfSize:14];
  titleLabel.textColor = UIColorFromRGB(0x0287d3);
  //  titleLabel.backgroundColor = [UIColor darkGrayColor];
  
  
  UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, self.nearByView.frame.size.width, 0.5)];
  lineView0.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [self.nearByView addSubview:lineView0];
  UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 30-0.5, self.nearByView.frame.size.width, 0.5)];
  lineView1.backgroundColor = UIColorFromRGB(0xd9d9d9);
  
  
  
  UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 0, 40, 30)];
  [moreButton setTitle:@"更多" forState:UIControlStateNormal];
  [moreButton addTarget:self action:@selector(moreNearbyAction) forControlEvents:UIControlEventTouchUpInside];
  [moreButton setImage:[UIImage imageNamed:@"btn_nearby_more"] forState:UIControlStateNormal];
  
  
  
  
  [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 37, 0, -8)];
  [moreButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
  [moreButton setTitleColor:UIColorFromRGB(0x11263B) forState:UIControlStateNormal];
  [titleView addSubview:moreButton];
  
  
  
  [self.nearByView addSubview:lineView1];
  
  
  [self.nearByView addSubview:titleLabel];
  [self.nearByView addSubview:titleView];
  
  CGFloat nearbyItemTubeWidth = (kScreenWidth -15) / 5.f;
  CGFloat xOffset = nearbyItemTubeWidth;
  CGFloat xPos = 7.5;
  
  
  NSUInteger count = [_nearbyItems count] > 5 ? 5 : [_nearbyItems count];
  for (NSUInteger i = 0; i < count; i++) {
      
    NearbyItem *aNearbyItem = self.nearbyItems[i];
    
    IconButton *ib = [[IconButton alloc] initWithNearByItem:aNearbyItem];
    ib.tag = [aNearbyItem.nearbyItemID integerValue];
    //    ib.backgroundColor = [UIColor blueColor];
    [ib addTarget:self action:@selector(nearbyCategoryAction:) forControlEvents:UIControlEventTouchUpInside];
    ib.frame = CGRectMake(xPos, 30 + 13, nearbyItemTubeWidth, 54);
    xPos += xOffset;
    
    //    CGFloat r  = ib.imageView.frame.size.height / 2.f;
    //    ib.imageView.layer.cornerRadius = r;
    //    ib.imageView.layer.masksToBounds = YES;
    [self.nearByView addSubview:ib];
    
    if (!_nearbyItemButtonArray) {
      _nearbyItemButtonArray = [[NSMutableArray alloc] init];
    }
    
    
    [_nearbyItemButtonArray addObject:ib];
  }
  [_nearbyItemButtonArray addObject:titleLabel];
  [_nearbyItemButtonArray addObject:moreButton];
  [_nearbyItemButtonArray addObject:titleView];
  
  UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 108 -.5f, kScreenWidth, .5f)];
  lineView2.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [self.nearByView addSubview:lineView2];
  //  self.nearByView
  [_nearbyItemButtonArray addObject:lineView0];
  [_nearbyItemButtonArray addObject:lineView1];
  [_nearbyItemButtonArray addObject:lineView2];
  [self addSubview:self.nearByView];
}


- (UIView *) singleViewWithPageIndex:(NSInteger)pageIndex {
  
  UIView *servicesPageView = [[UIView alloc] init];
  
  CGFloat serviceItemTubeWidth = (kScreenWidth - 30) / 4.f;
  CGFloat mainOffset = 0;
  
  NSInteger pageMaxSize = 0;
  if ([self.servicesItems count] < 8) {
    pageMaxSize = [self.servicesItems count];
  } else {
    pageMaxSize = ([self.servicesItems count] - pageIndex * 8) > 8 ? 8 : ([_servicesItems count] - pageIndex * 8);
  }
  
  NSInteger beginIndex = pageIndex * 8;
  
  if ([self.servicesItems count] > 0 ) {
    
    CGFloat xOffset = serviceItemTubeWidth;
    CGFloat yOffset = 92;
    
    CGFloat xPos = 15;
    CGFloat yPos =  mainOffset;
    NSInteger i = 0;
    for (i = beginIndex ; i < beginIndex + pageMaxSize; i++) {
      if (i % 4 == 0 && i > 0 && i % 8 != 0) {
        yPos += yOffset;
        xPos = 15;
      }
      ServicesItem *aServiceItem = [self.servicesItems objectAtIndex:i];
      IconButton *ib = [[IconButton alloc] initWithService:aServiceItem];
      
      ib.tag = [aServiceItem.servicesID integerValue];
      
      
      
      if ([aServiceItem.actionType isEqualToString:@"yulore/service"]) {
        [ib addTarget:self action:@selector(servicesAction:) forControlEvents:UIControlEventTouchUpInside];
      }
      else {
        [ib addTarget:self action:@selector(localservicesAction2:) forControlEvents:UIControlEventTouchUpInside];
      }
      
      
      ib.frame = CGRectMake(xPos, yPos, serviceItemTubeWidth, serviceItemTubeWidth);
      xPos += xOffset;
      CGFloat r  = ib.imageView.frame.size.height / 2.f ;
      
      ib.imageView.layer.cornerRadius = r;
      ib.imageView.layer.masksToBounds = YES;
      [servicesPageView addSubview:ib];
    }
    
  }
  
  return servicesPageView;
}




- (void)setupServicesView:(CGFloat) offset {
  
  
  if ([_servicesItems count] == 0) {
    return;
  }
  
  
  NSInteger pages = ceil([self.servicesItems count] / 8.f);
  
  NSInteger containerMaxLines = pages >= 2 ? 2 : ([self.servicesItems count] > 4 ? 2 : 1);
  
  
  CGFloat title_Button_margin = 15 + 30;
  CGRect f = CGRectMake(0, offset, kScreenWidth, containerMaxLines * 85 + 36 + 30);
  
  
  self.servicesView.frame = f;
  self.servicesView.backgroundColor = [UIColor whiteColor];
  self.servicesView.pagingEnabled = YES;
  self.servicesView.showsHorizontalScrollIndicator = NO;
  self.servicesView.showsVerticalScrollIndicator = NO;
  self.servicesView.contentSize = CGSizeMake(CGRectGetWidth(f) * pages, CGRectGetHeight(f));
  [self addSubview:self.servicesView];
  [self addSubview:[self serviceTitleView:offset]];
  
  _sevicesItemButtonArray = [[NSMutableArray alloc] init];
  
  
  for (int i = 0; i < pages; i++) {
    UIView *servicesPageView = [self singleViewWithPageIndex:i];
    
    int sectionALines =  ceil(([self.servicesItems count] - i * 8) / 4.f);
    
    
    if (sectionALines > 2) {
      sectionALines = 2;
    }
    CGRect servicesViewf = CGRectMake(kScreenWidth * i , title_Button_margin, kScreenWidth, sectionALines * 92);
    servicesPageView.frame = servicesViewf;
    [self.servicesView addSubview:servicesPageView];
    [_sevicesItemButtonArray addObject:servicesPageView];
  }
  
  //  self.servicesView.backgroundColor = [UIColor orangeColor];
  
  CGRect pageViewRect = f;
  pageViewRect.size.height = 36;
  pageViewRect.origin.y = f.origin.y + f.size.height - 36;
  UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height -.5f, kScreenWidth, .5f)];
  lineView1.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [self.servicesView addSubview:lineView1];
  if (pages > 1) {
      
    self.pageControl.frame = CGRectMake(0, f.origin.y + f.size.height - 36, kScreenWidth, 36);
    self.pageControl.numberOfPages =  pages;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = UIColorFromRGB(0x7f827f);
    self.pageControl.currentPageIndicatorTintColor  = UIColorFromRGB(0xff4a00);
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
  }
  
}



- (CGFloat)setupCategoriesViewWithYPos:(CGFloat)yPosInput {
  
  CGFloat xPos = 0;
  CGFloat yPos = 31;
  [self.categoriesItems addObjectsFromArray:self.localServicesItems];
  CGFloat screenCenter = kScreenWidth / 2.0;

    CGFloat buttonOffsetY =  50;
  for (int i = 0; i < [self.categoriesItems count]; i++) {
    
    xPos = ((i + 1) % 2 == 0) ? screenCenter + 0  : 0;
    yPos = ((i + 1) % 2 == 1 && i > 1) ? yPos += buttonOffsetY : yPos;
    
    
    CategoryButton *categoryItemButton = nil;
    
    if ([self.categoriesItems[i] isKindOfClass:[CategoryItem class]]) {
      CategoryItem *aCategoryItem = self.categoriesItems[i];
      categoryItemButton = [[CategoryButton alloc] initWithCategory:aCategoryItem];
      categoryItemButton.tag = [aCategoryItem.categoryID integerValue];
      [categoryItemButton addTarget:self
                             action:@selector(categoryAction:)
                   forControlEvents:UIControlEventTouchUpInside];
    } else if([self.categoriesItems[i] isKindOfClass:[ServicesItem class]]) {
      ServicesItem *aServicesItem = self.categoriesItems[i];
      categoryItemButton = [[CategoryButton alloc] initWithService:aServicesItem];
      categoryItemButton.tag = [aServicesItem.servicesID integerValue];
      [categoryItemButton addTarget:self
                             action:@selector(localServicesAction:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    
    [categoryItemButton setFrame:CGRectMake(xPos, yPos, screenCenter - 4, 50)];
    
    
    if (!_categoryItemButtonArray) {
      _categoryItemButtonArray = [[NSMutableArray alloc] init];
    }
    [_categoryItemButtonArray addObject:categoryItemButton];
    
    [self.categoryView addSubview:categoryItemButton];
    
  }
  CGFloat height =  30 + ceil([self.categoriesItems count] / 2.f) * buttonOffsetY;
  
  [self.categoryView setFrame:CGRectMake(0, yPosInput, kScreenWidth, height)];
  self.categoryView.backgroundColor = [UIColor whiteColor];
  [self addSubview:self.categoryView];
  return yPos;
}

- (UIView *)serviceTitleView:(CGFloat)offset {
  UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, offset, kScreenWidth, kServiceTitleHeigh)];
  UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, kScreenWidth, .5f)];
  lineView0.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [aView addSubview:lineView0];
  UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 30-0.5, kScreenWidth, .5f)];
  lineView1.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [aView addSubview:lineView1];
  
  
  aView.backgroundColor = [UIColor whiteColor];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, kServiceTitleHeigh)];
  titleLabel.text = @"快捷服务";
  titleLabel.font = [UIFont systemFontOfSize:14];
  titleLabel.textColor = UIColorFromRGB(0xf91b1b);
  [aView addSubview:titleLabel];
  
  return aView;
}



- (UIView *)hotCategoryViewTitleView {
  UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kServiceTitleHeigh)];
  UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(0, -0.5, kScreenWidth, .5f)];
  lineView0.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [aView addSubview:lineView0];
  UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 30-0.5, kScreenWidth, .5f)];
  lineView1.backgroundColor = UIColorFromRGB(0xd9d9d9);
  [aView addSubview:lineView1];
  
  
  aView.backgroundColor = [UIColor whiteColor];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, kServiceTitleHeigh)];
  titleLabel.text = @"热门分类";
  titleLabel.font = [UIFont systemFontOfSize:14];
  titleLabel.textColor = UIColorFromRGB(0x2765cc);
  [aView addSubview:titleLabel];
  
  return aView;
}
- (void)ruzhuzhongxin {
  //https://mp.dianhua.cn/bizctr/mobile.php/Index/miui?apikey=6WWpOS2NreERRbkJpYVVJd1lVZFZaMkw  change 2016.1.26
  NSString *url = [NSString stringWithFormat:@"https://mp.dianhua.cn/bizctr/mobile.php/Index/miui?apikey=%@&uid=%@", [YuloreApiManager sharedYuloreApiManager].apiKey, [OpenUDID value]];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
- (void)setupInCenter {
  CGFloat inCenterPos = self.categoryView.frame.origin.y +  self.categoryView.frame.size.height;
  self.centerButton.frame = CGRectMake(0, inCenterPos + 1.f, kScreenWidth, kScreenWidth * .28f);
  [self.centerButton addTarget:self action:@selector(ruzhuzhongxin) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.centerButton];
}
- (void)setup {
//  DLog(@"-A---- setup ------setup ------setup ------setup ------");
  if (!self.servicesItems) {
    return;
  }
  
  
  self.backgroundColor = UIColorFromRGB(0xf0f0f0);
  
  
  
  if (!_pageControl) {
    _pageControl = [[UIPageControl alloc] init];
    //  [self addSubview:_pageControl];
  }
  
  if (!_servicesView) {
    _servicesView = [[UIScrollView alloc] init];
    _servicesView.delegate = self;
    //    [_servicesView addSubview:[self serviceTitleView:0]];
    // [self addSubview:_servicesView];
    
  }
  
  if (!_nearByView) {
    _nearByView = [[UIView alloc] init];
    // [self addSubview:_servicesView];
    
  }
  
  if (!_userPathView) {
    _userPathView = [[UIView alloc] init];
    // [self addSubview:_servicesView];
    
  }
  
  
//  DLog(@"-A1---- setup ------setup ------setup ------setup ------");
  if (!_categoryView) {
    _categoryView = [[PartCategoryView alloc] init];
    [_categoryView addSubview:[self hotCategoryViewTitleView]];
    //    _categoryView.delegate = self;
    //    [_categoryView addSubview:[self serviceTitleView:0]];
    // [self addSubview:_servicesView];
    
  }
  else {
    [_categoryView setNeedsDisplay];
  }
  
//  DLog(@"-A2---- setup ------setup ------setup ------setup ------");
  
  if (!_centerButton) {
    _centerButton = [[UIButton alloc] init ];//WithFrame:CGRectMake(0, 0, width, width * .28f)];
    [_centerButton setImage:[UIImage imageNamed:@"bg_in_center"] forState:UIControlStateNormal];
  }
  
  NSMutableArray *imagesURL = [[NSMutableArray alloc] init];
  
  for (PromotionItem *aItem in _promotionItems) {
    NSURL *url = [NSURL URLWithString:aItem.iconURLString];
    [imagesURL addObject:url];
    NSString *fileName = [[aItem.iconURLString componentsSeparatedByString:@"/"] lastObject];
    
    dispatch_queue_t q = dispatch_queue_create("queue", 0);
    dispatch_async(q, ^{
      NSData *aData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aItem.iconURLString]];
      NSString *cachePath = [NSString pathForOfflineDataDirectoryWithFileName:fileName];
      
      [aData writeToFile:cachePath  atomically:YES];
      
    });
    
    
    
    //
  }
  //  _promotionItems
//  DLog(@"-B---- setup ------setup ------setup ------setup ------");
  
  //1080 x 334
  self.sdCycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, kADViewHeigh) imageURLsGroup:imagesURL];
  self.sdCycleScrollView.placeholderImage = [UIImage imageNamed:@"banner_gaokao"];
  
  if ([imagesURL count] > 1) {
    self.sdCycleScrollView.autoScrollTimeInterval = 4.0;
  }
  
  
  
  self.sdCycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
  self.sdCycleScrollView.delegate = self;
  [self addSubview:self.sdCycleScrollView];
  //  cycleScrollView2.titlesGroup = titles;
  //  cycleScrollView2.dotColor = [UIColor yellowColor]; // 自定义分页控件小圆标颜色
  //  cycleScrollView2.placeholderImage = [UIImage imageNamed:@"placeholder"];
  
  
  CGFloat mainOffset = 28;
  
  
  NSInteger pages = ceil([self.servicesItems count] / 8.f);
  NSInteger containerMaxLines = pages >= 2 ? 2 : ([self.servicesItems count] > 4 ? 2 : 1);
  CGFloat sectionBStart = mainOffset + containerMaxLines * 92 + 5 + kADViewHeigh;
//  DLog(@"-B2---- setup ------setup ------setup ------setup ------");
  [self setupServicesView:kADViewHeigh];
//  DLog(@"-C---- setup ------setup ------setup ------setup ------");
  
  [self nearByViewWithOffset: self.servicesView.frame.origin.y + self.servicesView.frame.size.height + 10 ];
  
  CGFloat categoryOffset = 10;
  if ([_userPathItems count]) {
    categoryOffset += 60;
    [self userPathViewWithOffset:_nearByView.frame.origin.y + _nearByView.frame.size.height + 10];
  }
  
  
  
  
  CGFloat yPos = [self setupCategoriesViewWithYPos:_nearByView.frame.origin.y + _nearByView.frame.size.height + categoryOffset];
  
  CGFloat frameHeigh = kScreenHeight + 20;
  [self setupInCenter];
  
  
  
  self.frame = CGRectMake(0, 0, kScreenWidth, frameHeigh);
  
  CGFloat offset = 0;
  if (IS_IOS8_OR_LATER) {
    offset = 40;
  }
  
  CGFloat contentSizeHeigh = self.centerButton.frame.origin.y +  self.centerButton.frame.size.height + 85;//yPos + 110 - offset; // sectionCStart + sectionCLines * 46 + 75;
  
  if (frameHeigh >= contentSizeHeigh) {
    // contentSizeHeigh = frameHeigh + 1;
  }
  
  self.contentSize = CGSizeMake(self.frame.size.width, contentSizeHeigh);
//  DLog(@"-D---- setup ------setup ------setup ------setup ------");
}


- (void)scrollViewDidScroll:(UIScrollView *)sender
{
  CGFloat pageWidth = sender.frame.size.width;
  int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  self.pageControl.currentPage = page;
}
- (void)changePage:(id)sender
{
  NSInteger page = self.pageControl.currentPage;
  
  // update the scroll view to the appropriate page
  CGRect frame = self.servicesView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;
  
  
  [self.servicesView scrollRectToVisible:frame animated:YES];
}

#pragma mark - HotCategoryView Delegate Action

- (void)moreNearbyAction {
  if ([_categoryDelegate respondsToSelector:@selector(didSelectNearbyButtonAction)]) {
    [_categoryDelegate didSelectNearbyButtonAction];
  }
  
}


- (void)categoryAction:(CategoryButton *)sender {
  
  for (CategoryItem *aCategory in self.categoriesItems) {
    if ([aCategory isKindOfClass:[CategoryItem class]]) {
      
      
      NSUInteger sid = [aCategory.categoryID integerValue];
      if(sid  ==  sender.tag) {
        if ([_categoryDelegate respondsToSelector:@selector(selectHotCategory:)]) {
          [_categoryDelegate selectHotCategory:aCategory];
          
          break;
        }
        
        
      }
    }
  }
}
- (void)servicesAction:(IconButton *)sender {
  //DLog(@"actionaction");
  for (ServicesItem *aService in self.servicesItems) {
    NSUInteger sid = [aService.servicesID integerValue];
    
    if(sid  ==  sender.tag) {
      if ([_categoryDelegate respondsToSelector:@selector(selectServices:type:)]) {
        [_categoryDelegate selectServices:aService type:MainViewItemsTypeCommonService];
        
        break;
      }
    }
    
  }
}

- (void)localservicesAction2:(IconButton *)sender {
  //DLog(@"actionaction");
  for (ServicesItem *aService in self.servicesItems) {
    NSUInteger sid = [aService.servicesID integerValue];
    
    if(sid  ==  sender.tag) {
      if ([_categoryDelegate respondsToSelector:@selector(selectServices:type:)]) {
        [_categoryDelegate selectServices:aService type:MainViewItemsTypeLocalService];
        break;
      }
    }
    
  }
}



//119
- (void)nearbyCategoryAction:(IconButton *)sender {
  //DLog(@"actionaction");
  
  for (NearbyItem *aNearby in self.nearbyItems) {
    if ([aNearby isKindOfClass:[NearbyItem class]]) {
      
      
      NSUInteger sid = [aNearby.nearbyItemID integerValue];
      if(sid  ==  sender.tag) {
        if ([_categoryDelegate respondsToSelector:@selector(selectHotCategory:)]) {
          [_categoryDelegate selectNearbyInfo:aNearby];
          
          break;
        }
        
        
      }
    }
  }
  
}

- (void)localServicesAction:(IconButton *)sender {
  //DLog(@"actionaction");
  for (ServicesItem *aService in self.localServicesItems) {
    
    NSUInteger sid = [aService.servicesID integerValue];
    
    if(sid  ==  sender.tag) {
      
      if ([_categoryDelegate respondsToSelector:@selector(selectServices:type:)]) {
        
        [_categoryDelegate selectServices:aService type:MainViewItemsTypeLocalService];
        break;
        
      }
      
    }
    
  }
}





- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
  if ([_categoryDelegate respondsToSelector:@selector(selectPromotionItem:)]) {
    [_categoryDelegate selectPromotionItem:self.promotionItems[index]];
  }
  
  
  
}
- (void)layoutSubviews {
  [super layoutSubviews];
  //  DLog(@"layoutSubviews-----------layoutSubviews");
  CGRect f = self.pageControl.frame;
  f.size.width = kScreenWidth;
  self.pageControl.frame = f;
}


@end
