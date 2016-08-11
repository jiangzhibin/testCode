//
//  DHBDownloadFetcher.m
//  Downloading
//
//  Created by Zhang Heyin on 15/8/10.
//  Copyright © 2015年 Yulore. All rights reserved.
//

#import "DHBDownloadFetcher.h"
#import "FileHash.h"
#import "NSString+MD5Check.h"
#import "DHBbspatchOC.h"
#import "AFDownloadRequestOperation.h"
#import "NSString+YuloreFilePath.h"
#import "DHBEnvironmentValidate.h"
#import "CommonTmp.h"


//#import "VirtualInterface.h"
#import "DHBErrorHelper.h"
#import "DHBFileOperation.h"
//#import "DHBUpdateLogging.h"
@interface DHBDownloadFetcher()
@property (nonatomic, strong) AFDownloadRequestOperation *downloadOperation;


@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) DHBUpdateItem *updateItem;
@end
@implementation DHBDownloadFetcher

+ (instancetype)sharedInstance {
  
  static DHBDownloadFetcher *_sharedDownloadFetcher = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    _sharedDownloadFetcher = [[self alloc] init];
    
  });
  
  return _sharedDownloadFetcher;
}


- (instancetype)init {
  self = [super init];
  if (self) {
    

  }
  return self;
}


- (NSString *)targetPathWithType:(DHBDownloadPackageType)type {
  
  NSString *targetPath = nil;
  switch (type) {
    case DHBDownloadPackageTypeDelta:
      targetPath = [NSString pathForDeltaOfflineFilePath];
      break;
      
    case DHBDownloadPackageTypeFull:
      targetPath = [NSString pathForFullOfflineFilePath];
      break;
      
  }
  
  return targetPath;
}


- (NSString *)md5WithUpdateItem:(DHBUpdateItem *)updateItem packageType:(DHBDownloadPackageType)packageType {
  NSString *MD5 = nil;
  if (packageType == DHBDownloadPackageTypeDelta) {
    MD5 = updateItem.deltaMD5;
  } else if (packageType == DHBDownloadPackageTypeFull) {
     MD5 = updateItem.fullMD5;
  }
  return MD5;
}


/**
 *  <#Description#>
 *
 *  @param progressBlock     <#progressBlock description#>
 *  @param completionHandler <#completionHandler description#>
 */
- (void)downloadingWithType:(DHBDownloadPackageType)packageType
              //   updateItem:(DHBUpdateItem *)updateItem
              progressBlock:(void (^)(double progress, long long totalBytes))progressBlock
          completionHandler:(void (^)(NSError *error))completionHandler {
    self.requestURL = nil;
  if (packageType == DHBDownloadPackageTypeDelta) {
    self.requestURL = [NSURL URLWithString:self.updateItem.deltaDownloadPath];
  } else if (packageType == DHBDownloadPackageTypeFull) {
    self.requestURL = [NSURL URLWithString:self.updateItem.fullDownloadPath];
  }
    NSLog(@"Downloading from %@", self.requestURL);


  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.requestURL];
  
  NSString *targetPath = [self targetPathWithType:packageType];
    NSString *targetPathUnzipped = [[NSString alloc] initWithFormat:@"%@_zip/",targetPath];

    NSLog(@"to %@ (%@)", targetPath,targetPathUnzipped);

  self.downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:urlRequest
                                                                    targetPath:targetPath
                                                                  shouldResume:YES];
  self.downloadOperation.shouldOverwrite = YES;
  NSError *error = nil;
  [self.downloadOperation deleteTempFileWithError:&error];
  
  NSLog(@"error deleteTempFileWithError %@", error);
  [self.downloadOperation start];
  [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *  operation, id  responseObject) {
    //    NSLog(@"Success");
    if (operation.response.statusCode != 200) {
      completionHandler([DHBErrorHelper errorResponse:operation.response.statusCode]);
      return;
    }

    NSString *testMD5 = nil;
    if (packageType == DHBDownloadPackageTypeDelta) {
      testMD5 = self.updateItem.deltaMD5;
    } else if (packageType == DHBDownloadPackageTypeFull) {
      testMD5 = self.updateItem.fullMD5;
    }

    NSError *error = nil;
    
      if (packageType == DHBDownloadPackageTypeFull){
          
          YuloreZipArchive *zip = [[YuloreZipArchive alloc] init];
          //   zip.progressBlock = progressBlock;
          zip.progressBlock = ^ (int percentage, int filesProcessed, int numFiles) {
              if (percentage == 100) {
                  //completionBlock(nil);
              }
          };
          BOOL result = NO;
          
          if ([zip UnzipOpenFile:targetPath]) {
              result = [zip UnzipFileTo:targetPathUnzipped overWrite:YES];//解压文件
              if (!result) {
                  //解压失败
                  NSLog(@"unzip fail................");
              } else if ([zip numFiles]>0) {
                  //解压成功
                  NSString * unzippedFile=[[NSString alloc] initWithFormat:@"%@%@",targetPathUnzipped,[[zip getZipFileContents] objectAtIndex:0]];
                  NSLog(@"unzip success.............%@",unzippedFile);
                  [zip UnzipCloseFile];
                  
                  NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPathUnzipped error:NULL];
                  for (int count = 0; count < (int)[directoryContent count]; count++)
                  {
                      NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
                  }
                  
                  [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
                  [[NSFileManager defaultManager] moveItemAtPath:unzippedFile toPath:targetPath error:&error];
                  [targetPath fileValidMD5WithMD5String:testMD5 error:&error];
                  if (error!=nil){
                      NSLog(@"error fileValidMD5WithMD5String %@", error);
                  }
              }
          }
          //full package, unzip first
      } else {
          [targetPath fileValidMD5WithMD5String:testMD5 error:&error];
          if (error!=nil){
              NSLog(@"error fileValidMD5WithMD5String %@", error);
          }
          //delta package, not zipped
      }
    completionHandler(error);
  } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
    
    completionHandler(error);
  }];
  
  
  [self.downloadOperation setDownloadProgressBlock:^ void(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    
    float progress = totalBytesRead / (float)totalBytesExpectedToRead;
    progressBlock(progress, totalBytesExpectedToRead);
    
  }];
 
}

/**
 *  <#Description#>
 *
 *  @param progressBlock     <#progressBlock description#>
 *  @param completionHandler <#completionHandler description#>
 */
- (void)baseDownloadingWithType:(DHBDownloadPackageType)packageType
                     updateItem:(DHBUpdateItem *)updateItem
                  progressBlock:(void (^)(double progress, long long totalBytes))progressBlock
              completionHandler:(void (^)(BOOL retry, NSError *error))completionHandler  {

  self.updateItem = updateItem;
  
  /**
   *  运行环境检测是否符合要求
   */
  NSError *error = nil;
  if (![DHBEnvironmentValidate environmentValidate:&error]) {
    
    completionHandler(NO, error);
    return;
  }
  
  /**
   *  环境符合，可以下载操作
   */
  [self downloadingWithType:packageType  progressBlock:^(double progress, long long totalBytes) {
    //进度回调
    progressBlock(progress, totalBytes);
    
  } completionHandler:^(NSError *error)
   {
     if (error) {
       
       [self.updateItem failed];
       completionHandler([self.updateItem isNeedRetry], error);
       
     }
     else {
       [self afterDownloadingWithType:packageType completionHandler:^(NSError *error) {
         
         /**
          *  如果没有异常重置次版本的版本报错记录
          */
         if (error == nil) {
          
         }
         
         completionHandler([self.updateItem isNeedRetry], error);
       }];
     }
   }];
  
}

/**
 *  <#Description#>
 *
 *  @param completionHandler <#completionHandler description#>
 */
- (void)bspatchActionCompletionHandler:(void (^)(NSError *error))completionHandler  {
  
  NSString *oldFile = [NSString pathForFullOfflineFilePath];
  
  NSString *deltaFile = [NSString pathForDeltaOfflineFilePath];
  
  NSString *newFile = [NSString pathForPreOfflineFilePath];
  
  
  [DHBbspatchOC DHBbspatchWithOldFile:oldFile newFile:newFile patchFile:deltaFile
                    completionHandler:^(NSError *bspatchError)
   {
     if (bspatchError) {
       completionHandler(bspatchError);
       
       return;
     }

     /**
      *  1 check delta file md5 / 检查delta文件的MD5
      */
     NSString *md5 = self.updateItem.deltaMD5;
     NSError *error = nil;
     [deltaFile fileValidMD5WithMD5String:md5 error:&error];
     
     if (error) {
       completionHandler(error);
       
       return;
     }

     /**
      *  生成新文件的MD5
      */
     [newFile fileValidMD5WithMD5String:self.updateItem.fullMD5 error:&error];
     if (error) {
       
       completionHandler(error);
    
       return;
     }
    
     /**
      *  2 文件更新
      */
     error = [DHBFileOperation errorWithFileUpdateOperation];

       completionHandler(error);

     
   }];
  
}

- (void)afterDownloadingWithType:(DHBDownloadPackageType)type
               completionHandler:(void (^)(NSError *error))completionHandler{
  /**
   *  bspatch
   */
    NSLog(@"After Download");
  if (type == DHBDownloadPackageTypeDelta) {
    [self bspatchActionCompletionHandler:^(NSError *error) {
      
      if (error) {
        [self.updateItem failed];
      }
      else {
        //[DHBInitBusiness updateCurrentVersionWithItem:self.updateItem];
      }
      
      completionHandler(error);
    }];
    
  }
  else {
    /**
     *  更新版本
     */
    
    //[DHBInitBusiness updateCurrentVersionWithItem:self.updateItem];
    
    completionHandler(nil);
  }
}
@end
