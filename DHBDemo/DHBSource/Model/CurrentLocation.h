//
//  CurrentLocation.h
//  PrototypeDesign
//
//  Created by zhangheyin on 12-9-26.
//  Copyright (c) 2012年 zhangheyin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class City;
//@protocol  CurrentLocationAddressDelegate <NSObject>
//- (void) loadCurrentAddressString:(NSString *)addressString;
//- (void) loadCurrentAddress:(NSDictionary *)currentCity;
//@end

//@protocol CurrentLocationCoordinate <NSObject>
//- (void) loadCurrentCoordinate:(CLLocationCoordinate2D)coordinate;
//@end
typedef void (^LocationCompletionHandler)(CLLocation *currentLocation, City *currentCity ,NSError *error);

@interface CurrentLocation : NSObject

@property (nonatomic, strong) NSDictionary *currentCity;
@property (nonatomic, assign) BOOL isLocating;
- (BOOL) locationServicesAvailable;
//<CLLocationManagerDelegate>
//@property (nonatomic, strong) CLLocationManager *locationManager;
//@property (nonatomic, strong) NSMutableArray *locationMeasurements;
//@property (nonatomic, strong) CLLocation *bestEffortAtLocation;
//@property (nonatomic, strong) City *currentCity;
//-(void)change:(CLLocation *)newLocation;
//- (void)startUpdate;
//+ (CLLocationCoordinate2D)currentCoordinate;
////+ (NSString *) detailAddressFromSever:(CLLocationCoordinate2D)latestLocationCoordinate;
////+ (double) countDistance:(double)latitude1 longitude1:(double)longitude1 latitude2:(double)latitude2 longitude2:(double)longitude2;
////+ (double) countDistance2:(double)latitude1 longitude1:(double)longitude1 latitude2:(double)latitude2 longitude2:(double)longitude2;
//@property (nonatomic, assign) id<CurrentLocationAddressDelegate> addressDelegate;
//@property (nonatomic, assign) id<CurrentLocationCoordinate> coordinateDelegate;
//
+ (BOOL)needLocation;
+ (CLLocationCoordinate2D)currentCoordinate;
+ (instancetype)sharedInstance;
- (void)startingForLocation:(LocationCompletionHandler)completionHandler;

@end
