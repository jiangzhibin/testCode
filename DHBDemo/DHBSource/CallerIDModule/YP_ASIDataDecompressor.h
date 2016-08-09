//
//  YP_ASIDataDecompressor.h
//  Part of YP_ASIHTTPRequest -> http://allseeing-i.com/YP_ASIHTTPRequest
//
//  Created by Ben Copsey on 17/08/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

// This is a helper class used by YP_ASIHTTPRequest to handle inflating (decompressing) data in memory and on disk
// You may also find it helpful if you need to inflate data and files yourself - see the class methods below
// Most of the zlib stuff is based on the sample code by Mark Adler available at http://zlib.net

#import <Foundation/Foundation.h>
#import <zlib.h>
typedef enum _YP_ASINetworkErrorType {
  YP_ASIConnectionFailureErrorType = 1,
  YP_ASIRequestTimedOutErrorType = 2,
  YP_ASIAuthenticationErrorType = 3,
  YP_ASIRequestCancelledErrorType = 4,
  YP_ASIUnableToCreateRequestErrorType = 5,
  YP_ASIInternalErrorWhileBuildingRequestType  = 6,
  YP_ASIInternalErrorWhileApplyingCredentialsType  = 7,
	YP_ASIFileManagementError = 8,
	YP_ASITooMuchRedirectionErrorType = 9,
	YP_ASIUnhandledExceptionError = 10,
	YP_ASICompressionError = 11
	
} YP_ASINetworkErrorType;
@interface YP_ASIDataDecompressor : NSObject {
	BOOL streamReady;
	z_stream zStream;
}

// Convenience constructor will call setupStream for you
+ (id)decompressor;

// Uncompress the passed chunk of data
- (NSData *)uncompressBytes:(Bytef *)bytes length:(NSUInteger)length error:(NSError **)err;

// Convenience method - pass it some deflated data, and you'll get inflated data back
+ (NSData *)uncompressData:(NSData*)compressedData error:(NSError **)err;

// Convenience method - pass it a file containing deflated data in sourcePath, and it will write inflated data to destinationPath
+ (BOOL)uncompressDataFromFile:(NSString *)sourcePath toFile:(NSString *)destinationPath error:(NSError **)err;

// Sets up zlib to handle the inflating. You only need to call this yourself if you aren't using the convenience constructor 'decompressor'
- (NSError *)setupStream;

// Tells zlib to clean up. You need to call this if you need to cancel inflating part way through
// If inflating finishes or fails, this method will be called automatically
- (NSError *)closeStream;

@property (assign, readonly) BOOL streamReady;
@end
