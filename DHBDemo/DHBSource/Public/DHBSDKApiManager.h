//
//  YuloreApiManager.h
//  DHBDemo
//
//  Created by Zhang Heyin on 15/2/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//
//  Modified by 蒋兵兵 on 16/08/11
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DHBSDKCommonType.h"

@class DHBSDKUpdateItem;
@class DHBSDKResolveItemNew;

@interface DHBSDKApiManager : NSObject

#pragma mark - 必须
@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, copy) NSString *signature;

/// 用户所在城市id,默认为@"0" 代表全部城市，用户修改城市后，需重新赋值
@property (nonatomic, copy) NSString *cityId;

/// 电话邦host https://apis-ios.dianhua.cn/
@property (nonatomic, copy) NSString *host;

/// iOS10以上 实现来电识别功能时，必须设置此参数，用于宿主App和Extension的数据共享；无此需求可不设置 任何iOS版本，设置此属性后，号码的数据文件 将存储到共享容器中。不设置，则存储到Document目录中。（点击Project->主target->Capablities -> App Groups 打开开关，并勾选app groups，被勾选的group名字，就是shareGroupIdentifier应该设置的值
@property (nonatomic, copy) NSString *shareGroupIdentifier;

#pragma mark - 可选
/// 用户定位信息
@property (nonatomic, assign) CLLocationCoordinate2D  coordinate;

/// 允许执行下载操作的网络类型(默认DHBSDKDownloadNetworkTypeWifiOnly)
@property (nonatomic, assign) DHBSDKDownloadNetworkType downloadNetworkType;


/**
 * 合并后的数据文件路径 （当前分1000个子文件)
 * 
 for (int i=0;i<1000;i++) {
    @autoreleasepool {
        NSString * filePathI=[[NSString alloc] initWithFormat:@"%@%d",filePath,i];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePathI])
        {
            NSLog(@"<<< %d >文件不存在:%@",i,filePathI);
            break;
        }
        NSMutableDictionary *contentDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePathI];
        count += [[contentDict allKeys] count];
        filePathI=nil;
}
 */
/// 合并后的数据文件路径
@property (nonatomic, readonly) NSString *pathForBridgeOfflineFilePath;

+ (instancetype)shareManager;


#pragma mark - 注册相关
/**
 *  初始化所需ApiKey以及密码
 *
 *  @param apikey    所需apikey
 *  @param signature 所需signature
 *  @param host      电话邦host https://apis-ios.dianhua.cn/
 *
 *  @return 是否设置成功
 */
+ (BOOL) registerApp:(NSString *)apikey
           signature:(NSString *)signature
                host:(NSString *)host
     completionBlock:(void (^)(NSError *error) )completionBlock;

/**
 注册状态
 
 @return YES:当前已经注册  NO:尚未注册
 */
+ (BOOL)registered;

#pragma mark - 号码查询及标记
/**
 查询号码信息

 @param teleNumber        号码
 @param completionHandler 查询结果回调
 */
+ (void)searchTeleNumber:(NSString *)teleNumber
           completionHandler:(void (^)( DHBSDKResolveItemNew *resolveItem, NSError *error) )completionHandler;

/**
 在线标记号码
 
 @param aNumber             电话号码
 @param flagInfomation      被标记的信息
 @param completeBlock       标记完成的回调
 */
+ (void)markTeleNumberOnlineWithNumber:(NSString *)aNumber
                        flagInfomation:(NSString *)flagInfomation
                     completionHandler:(void (^)( BOOL successed, NSError *error))completeBlock;


#pragma mark - 数据获取及下载
/**
 数据信息获取
 如 更新包下载地址及md5等，详情见DHBSDKUpdateItem.h
 @param completionHandler 回调
 */
+ (void)dataInfoFetcherCompletionHandler:(void(^)(DHBSDKUpdateItem *updateItem, NSError *error))completionHandler;


/**
 下载 全量/增量包
 
 @param updateItem        下载所需的信息model
 @param packageType          下载的数据类型
 @param progressBlock     进度回调
 @param completionHandler 下载结束回调，error == nil，则下载失败；error == nil,下载成功
 */
+ (void)downloadDataWithUpdateItem:(DHBSDKUpdateItem *)updateItem
                          dataType:(DHBDownloadPackageType)packageType
                     progressBlock:(void(^)(double progress))progressBlock
                 completionHandler:(void(^)(NSError *error))completionHandler;

@end
