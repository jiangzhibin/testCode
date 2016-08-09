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
#import "YuloreAPI.h"
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

- (IBAction)downloadAction:(id)sender {
    [YuloreApiManager sharedYuloreApiManager].apiKey = APIKEY_Download;
    [YuloreApiManager sharedYuloreApiManager].signature = APISIG2;
    [YuloreApiManager sharedYuloreApiManager].cityId = @"2";
    
    
    
    [YuloreApiManager registerApp:APIKEY_Download signature:APISIG2 completionBlock:^(NSError *error) {
        DHBDownloadPackageType downloadType = DHBDownloadPackageTypeFull;
        //DHBDownloadPackageType downloadType = DHBDownloadPackageTypeFull;
        
        [[DHBDataFetcher sharedInstance] fullDataFetcherCompletionHandler:^(NSArray *fullPackageList, NSArray *deltaPackageList, NSError *error) {
            DHBUpdateItem *updateItem = [deltaPackageList firstObject];
            if (updateItem == nil) {
                return ;
            }
            [[DHBDownloadFetcher sharedInstance] baseDownloadingWithType:downloadType updateItem:updateItem progressBlock:^(double progress, long long totalBytes) {
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
