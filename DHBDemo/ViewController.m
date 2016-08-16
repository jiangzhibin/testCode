//
//  ViewController.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/4.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "ViewController.h"
#import "DHBDownloadFetcher.h"
#import "CommonTmp.h"
#import "DHBDataFetcher.h"
#import "DHBCovertIndexContent.h"
#import "YuloreApiManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

#define APIKEY_Download @"mtyFwikuZ8ARgmwhljlidzxbevhrWrjL"

#define APIKEY @"6WWpOS2NreERRbkJpYVVJd1lVZFZaMkw"
#define APISIG @"yv3%D_d&-hq3F8JmDr!?cf#dk3pvs2#D_d&-vaSc7szVs!jcCs5$NvY2ul__o)3s!__Ns$__g4*d__cne@__c#bst9sk-c$xA__5#jclsOc9^bv2__7cJ&h__ld4=U3Kij*sD5&_ds2{hX13e2@s9C#s3#zF!v%ba^2Dc"

#define APIKEY2 @"abFRSWVlxTYkhZYbCcZSdapLVlllteGX"
#define APISIG2 @"E5UaGxNMkUxTVRrd01EbGtNemN5WlRoaFpUUmpZVFV3TnprM01UVT1ZV1l6TXpjell6QXlNVFV6TUdNMU4ySmtNMlExWXpWaU1XRm1OMlptTkdRPVpUSXlNR0UzWWpKalkyUXhNbUptWTJFNVl6QTRObUprTVRjNE1UUm1"
#define kDHBHost @"https://apis-ios.dianhua.cn/"

- (IBAction)downloadAction:(id)sender {

    [YuloreApiManager registerApp:APIKEY_Download signature:APISIG2 host:kDHBHost cityId:@"2" completionBlock:^(NSError *error) {
        // 在线标记 APIKEY2
//        [YuloreApiManager markTeleNumberOnlineWithNumber:@"12315" flagInfomation:@"荷塘蛋花粥" completionHandler:^(BOOL successed, NSError *error) {
//            NSLog(@"标记号码:%zd  error:%@",successed,error);
//        }];
        
        // 在线查询
//        [YuloreApiManager searchTeleNumber:@"12315" completionHandler:^(ResolveItemNew *resolveItem, NSError *error) {
//            NSLog(@"%@",resolveItem);
//            NSLog(@"error:%@",error);
//        }];
//
//        
//                return ;
        
        
        
//        [[DHBDataFetcher sharedInstance] fullDataFetcherCompletionHandler:^(NSArray *fullPackageList, NSArray *deltaPackageList, NSError *error) {
//            
//        }];
//        return ;
        
        [YuloreApiManager dataInfoFetcherCompletionHandler:^(DHBSDKUpdateItem *updateItem, NSError *error) {
            [YuloreApiManager downloadDataWithUpdateItem:updateItem dataType:DHBSDKDownloadDataTypeFull progressBlock:^(double progress) {
                NSLog(@"进度:%f",progress);
            } completionHandler:^(NSError *error) {
                NSLog(@"下载结果 error:%@",error);
            }];
        }];
        
        
        return;
        [[DHBDataFetcher sharedInstance] dataFetcherCompletionHandler:^(DHBSDKUpdateItem *updateItem, NSError *error) {
            if (updateItem == nil) {
                return ;
            }
            
            [[DHBDownloadFetcher sharedInstance] baseDownloadingWithType:DHBDownloadPackageTypeDelta updateItem:updateItem progressBlock:^(double progress, long long totalBytes) {
                NSLog(@"下载进度:%f totalBytes:%lld",progress,totalBytes);
            } completionHandler:^(BOOL retry, NSError *error) {
                NSLog(@"下载完成操作完成,error:%@",error);
                if (error) {
                    NSLog(@"下载失败");
                    return ;
                }
                
                
                [[DHBCovertIndexContent sharedInstance] needReload];
                
                dispatch_queue_t q = dispatch_queue_create("com.yulore.callerid.dataloader", 0);
                dispatch_async(q, ^{
                    [[DHBCovertIndexContent sharedInstance] readDataFromFile:^(float progress) {
                        NSLog(@"\n\n\nreadDataFromFile:\n%f",progress);
                    } completionHandler:^(NSError *error) {
                        ;
                    }];
                });
            }];
        }];
    }];
}

- (IBAction)btnReadDataToMemory:(id)sender {
    NSString *filePath = [NSString pathForBridgeOfflineFilePath];
    NSUInteger count = 0;
    for (int i=0;i<1000;i++) {
        @autoreleasepool {
            NSString * filePathI=[[NSString alloc] initWithFormat:@"%@%d",filePath,i];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePathI])
            {
                NSLog(@"<<< %d >文件不存在:%@",i,filePathI);
                break;
            }
            //            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePathI error:nil] fileSize];
            NSMutableDictionary *contentDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePathI];
            count += [[contentDict allKeys] count];
            //            phoneNumbers = [phoneNumbers sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
            //            NSLog(@"phoneNumbers:%@",contentDict);
            //            for (NSString * phoneNumber in phoneNumbers) {
            //                NSString *label = [contentDict objectForKey:phoneNumber];
            //
            //                NSLog(@"PN: %@",phoneNumber);
            //            }
            //            usleep(300000);
            //            [[NSFileManager defaultManager] removeItemAtPath:filePathI error:nil];
            filePathI=nil;
        }
    }
    NSLog(@"记录总数:%zd",count);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
