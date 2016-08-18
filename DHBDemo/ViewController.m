//
//  ViewController.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/4.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "ViewController.h"
#import "DHBSDKDownloadFetcher.h"
#import "CommonTmp.h"
#import "DHBSDKDataFetcher.h"
#import "DHBSDKCovertIndexContent.h"
#import "DHBSDKApiManager.h"

@interface ViewController ()

@end

@implementation ViewController


#define APIKEY_Download @"mtyFwikuZ8ARgmwhljlidzxbevhrWrjL"

#define APIKEY @"6WWpOS2NreERRbkJpYVVJd1lVZFZaMkw"
#define APISIG @"yv3%D_d&-hq3F8JmDr!?cf#dk3pvs2#D_d&-vaSc7szVs!jcCs5$NvY2ul__o)3s!__Ns$__g4*d__cne@__c#bst9sk-c$xA__5#jclsOc9^bv2__7cJ&h__ld4=U3Kij*sD5&_ds2{hX13e2@s9C#s3#zF!v%ba^2Dc"

#define APIKEY2 @"abFRSWVlxTYkhZYbCcZSdapLVlllteGX"
#define APISIG2 @"E5UaGxNMkUxTVRrd01EbGtNemN5WlRoaFpUUmpZVFV3TnprM01UVT1ZV1l6TXpjell6QXlNVFV6TUdNMU4ySmtNMlExWXpWaU1XRm1OMlptTkdRPVpUSXlNR0UzWWpKalkyUXhNbUptWTJFNVl6QTRObUprTVRjNE1UUm1"
#define kDHBHost @"https://apis-ios.dianhua.cn/"


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - 下载
- (IBAction)downloadAction:(id)sender {
//    [DHBSDKApiManager registerApp:nil signature:nil host:nil cityId:nil shareGroupIdentifier:nil completionBlock:nil];
//    return;
    [DHBSDKApiManager shareManager].downloadNetworkType = DHBSDKDownloadNetworkTypeAllAllow;
    [DHBSDKApiManager registerApp:APIKEY_Download
                        signature:APISIG2
                             host:kDHBHost
                           cityId:@"0"
             shareGroupIdentifier:nil
                  completionBlock:^(NSError *error) {
        [DHBSDKApiManager shareManager].shareGroupIdentifier = @"group.yulore";
        [DHBSDKApiManager dataInfoFetcherCompletionHandler:^(DHBSDKUpdateItem *updateItem, NSError *error) {
            /*
             fullDownloadPath:http://s3.dianhua.cn/chk/flag/1_mtyF_flag_86_61.zip,
             fullMD5:a19a05255a33b5384641e9dd740524be,
             fullSize:2698755,
             fullVersion:61,
             DHBDownloadPackageTypeDelta,
             DHBDownloadPackageTypeFull
             */
//                        updateItem.fullMD5 = @"a19a05255a33b5384641e9dd740524be";
//                        updateItem.fullDownloadPath = @"http://s3.dianhua.cn/chk/flag/1_mtyF_flag_86_61.zip";
//                        updateItem.fullSize = 2698755;
//                        updateItem.fullVersion = 61;
            
            [DHBSDKApiManager downloadDataWithUpdateItem:updateItem dataType:DHBDownloadPackageTypeFull progressBlock:^(double progress) {
                NSLog(@"进度:%f",progress);
            } completionHandler:^(NSError *error) {
                NSLog(@"下载完成 error:%@",error);
            }];
        }];
    }];
}
- (IBAction)accessDataAction:(id)sender {
    NSString *filePath = [DHBSDKApiManager shareManager].pathForBridgeOfflineFilePath;
    NSUInteger count = 0;
    for (int i=0;i<1000;i++) {
        @autoreleasepool {
            NSString * filePathI=[[NSString alloc] initWithFormat:@"%@%d",filePath,i];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePathI])
            {
                //                NSLog(@"<<< %d >文件不存在:%@",i,filePathI);
                break;
            }
            NSMutableDictionary *contentDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePathI];
            count += [[contentDict allKeys] count];
            filePathI=nil;
        }
    }
    NSLog(@"记录总数:%zd",count);
}

#pragma mark - 在线标记
- (IBAction)onlineMarkAction:(id)sender {
    [DHBSDKApiManager registerApp:APIKEY2
                         signature:APISIG2
                              host:kDHBHost
                            cityId:@"0"
              shareGroupIdentifier:nil
                   completionBlock:^(NSError *error) {
        [DHBSDKApiManager markTeleNumberOnlineWithNumber:@"13146022990" flagInfomation:@"推销" completionHandler:^(BOOL successed, NSError *error) {
            NSLog(@"标记号码:%zd  error:%@",successed,error);
        }];
    }];
}

#pragma mark - 在线识别
- (IBAction)onlineRecognizeAction:(id)sender {
    [DHBSDKApiManager registerApp:APIKEY2
                         signature:APISIG2
                              host:kDHBHost
                            cityId:@"0"
              shareGroupIdentifier:nil
                  completionBlock:^(NSError *error) {
        [DHBSDKApiManager searchTeleNumber:@"12315" completionHandler:^(DHBSDKResolveItemNew *resolveItem, NSError *error) {
            NSLog(@"%@",resolveItem);
            NSLog(@"error:%@",error);
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
