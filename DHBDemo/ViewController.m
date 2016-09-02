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


#define APIKEY @"mtyFwikuZ8ARgmwhljlidzxbevhrWrjL"
#define APISIG @"nsFwF52FnwvbdjynaqmfKlyb7Tq8eqAlqKhyXoWBvkvag0H1zKFFETY6Ez4saafzTxsqpuRnm4SQaqdKj4khxFAkbaxppCJidgQw2ojFpm4WpUutqcpNuPoFad0xcpZwrgxizszkthcmxq1brXtozwCpDm5xcoTCygLdu"

#define kDHBHost @"https://apis-ios.dianhua.cn/"


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [DHBSDKApiManager registerApp:APIKEY
                        signature:APISIG
                             host:kDHBHost
                           cityId:nil
             shareGroupIdentifier:nil
                  completionBlock:^(NSError *error) {
        
                  }];
}

#pragma mark - 下载
- (IBAction)downloadAction:(id)sender {
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
    [DHBSDKApiManager registerApp:APIKEY
                         signature:APISIG
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
    [DHBSDKApiManager registerApp:APIKEY
                         signature:APISIG
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
