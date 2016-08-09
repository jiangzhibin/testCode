//
//  CurrentLocation.m
//  PrototypeDesign
//
//  Created by zhangheyin on 12-9-26.
//  Copyright (c) 2012年 zhangheyin. All rights reserved.
//

#import "CurrentLocation.h"
#import "CityHelper.h"
#import "INTULocationManager.h"
#import "City.h"
@interface CurrentLocation ()
@property (nonatomic, strong)     CLGeocoder *geocoder;
@property (nonatomic, assign)     NSInteger requestID;
@end


@implementation CurrentLocation

typedef void (^CurrentLocationCompletionHandler)(CLLocation *currentLocation ,NSError *error);

static id _sharedInstance;
+ (instancetype)sharedInstance
{
  static dispatch_once_t _onceToken;
  dispatch_once(&_onceToken, ^{
    _sharedInstance = [[self alloc] init];
  });
  return _sharedInstance;
}


- (instancetype)init {

  self = [super init];
  if (self) {
    _geocoder=[[CLGeocoder alloc] init];
   // _currentCity = [[City alloc] init];
  }
  return self;
}

- (void)locationWithBlock:(CurrentLocationCompletionHandler)completionHandler {
  INTULocationManager *locMgr = [INTULocationManager sharedInstance];
  self.requestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                     timeout:10
                        delayUntilAuthorized:YES
                                       block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status)
   {
     
     if (status == INTULocationStatusSuccess) {
       completionHandler(currentLocation, nil);
       // achievedAccuracy is at least the desired accuracy (potentially better)
     //  NSString *message = [NSString stringWithFormat:@"Location request successful! Current Location:\n%@", currentLocation];
     //  DLog(@"%@", message);
     }
     else if (status == INTULocationStatusTimedOut) {
       //Error Domain=NSURLErrorDomain Code=-1001 "请求超时。" UserInfo=0x1742e5580 {NSUnderlyingError=0x17424d440 "请求超时。", NSErrorFailingURLStringKey=http://alog.umeng.com/app_logs, NSErrorFailingURLKey=http://alog.umeng.com/app_logs, NSLocalizedDescription=请求超时。}
       NSError *error = [[NSError alloc] initWithDomain:@"定位超时" code:-10000 userInfo:@{@"NSLocalizedDescription": @"定位超时"}];
       NSLog(@"%@",error);
        completionHandler(currentLocation, nil);
       // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
      // NSString *message =  [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
       //DLog(@"%@", message);
     }
     else {
       // An error occurred
       if (status == INTULocationStatusServicesNotDetermined) {
         //   strongSelf.statusLabel.text = @"Error: User has not responded to the permissions alert.";
       } else if (status == INTULocationStatusServicesDenied) {
         //   strongSelf.statusLabel.text = @"Error: User has denied this app permissions to access device location.";
       } else if (status == INTULocationStatusServicesRestricted) {
         // strongSelf.statusLabel.text = @"Error: User is restricted from using location services by a usage policy.";
       } else if (status == INTULocationStatusServicesDisabled) {
         //  strongSelf.statusLabel.text = @"Error: Location services are turned off for all apps on this device.";
       } else {
         //    strongSelf.statusLabel.text = @"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
       }
     }
     
     // strongSelf.locationRequestID = NSNotFound;
     
     
   }];
  
}


- (void)updateCurrentCoordinate:(CLLocationCoordinate2D)coordinate {
  NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
  
  [pref setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"coordinatelatitude"];
  [pref setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"coordinatelongitude"];
  [pref synchronize];
}


- (void)startingForLocation:(LocationCompletionHandler)completionHandler {
  if (self.isLocating) {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr cancelLocationRequest:self.requestID];
  }
  
  
  
  self.isLocating = YES;
  [self locationWithBlock:^(CLLocation *currentLocation, NSError *error) {
    
    
    if (error) {
      completionHandler(currentLocation, nil, error);
    }
    
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    
    NSNumber *timer  = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    CLLocationCoordinate2D coordinate = currentLocation.coordinate;
    [pref setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"coordinatelatitude"];
    [pref setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"coordinatelongitude"];
    [pref setObject:timer forKey:@"lastlocatingtime"];
    [pref synchronize];
    

    [self.geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error)
     {
       self.isLocating = NO;
       if (error) {
         completionHandler(currentLocation, nil, error);
         return;
       }
       
       //  [self updateCurrentCoordinate:currentLocation.coordinate];
       if (placemarks.count > 0) {
         CLPlacemark *placemark=[placemarks objectAtIndex:0];
//         DLog(@"我我的:%@\n country:%@\n postalCode:%@\n ISOcountryCode:%@\n ocean:%@\n inlandWater:%@\n locality:%@\n subLocality:%@ \n administrativeArea:%@\n subAdministrativeArea:%@\n thoroughfare:%@\n subThoroughfare:%@\n",
//               placemark.name,
//               placemark.country,
//               placemark.postalCode,
//               placemark.ISOcountryCode,
//               placemark.ocean,
//               placemark.inlandWater,
//               placemark.administrativeArea,
//               placemark.subAdministrativeArea,
//               placemark.locality,
//               placemark.subLocality,
//               placemark.thoroughfare,
//               placemark.subThoroughfare);
         //   NSString *address = placemark.name;
         
         //  DLog(@"addressDictionary %@", placemark.addressDictionary);
         //  NSString *cityLocality = placemark.locality;
         NSMutableArray *cities = [CityHelper allCityNative];
         
         
         for (NSDictionary *aCity in cities) {
           
           NSString *cityName = [aCity valueForKey:@"name"];
           NSString *citypinyin = [aCity valueForKey:@"pyf"];
           if ([placemark.locality rangeOfString:cityName].location != NSNotFound    || [placemark.locality rangeOfString:citypinyin].location != NSNotFound ) {

             
             City *currentCity = [[City alloc] initWithDictionary:aCity];
                self.currentCity = aCity;

             
             [CityHelper SetLocationCurrentCity:currentCity];
             

             completionHandler(currentLocation, currentCity, error);
             break;

           }

           
           
         }
       }
     }];
    
  }];
   
}



//
//- (void)startUpdate {
//  [self.locationManager stopUpdatingLocation];
//
//  self.bestEffortAtLocation = nil;
//  [self.locationManager startUpdatingLocation];
//}
//- (id)init
//{
//  self = [super init];
//  if (self) {
//    //DLog(@"Initialized");
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//    [self.locationManager startUpdatingLocation];
//    BOOL enable = [CLLocationManager locationServicesEnabled];
//    DLog(@"%@", enable? @"Enabled" : @"Not Enabled");
//  }
//
//  return self;
//}
//
///*
// * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
// *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
// *      accuracy, or both together.
// */
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//  //DLog(@"didUpdateToLocation");
//  // store all of the measurements, just so we can see what kind of data we might receive
//  [self.locationMeasurements addObject:newLocation];
//  // test the age of the location measurement to determine if the measurement is cached
//  // in most cases you will not want to rely on cached measurements
//  NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//  if (locationAge > 20.0) return;
//  // test that the horizontal accuracy does not indicate an invalid measurement
//  if (newLocation.horizontalAccuracy < 0) return;
//  // test the measurement to see if it is more accurate than the previous measurement
//  if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
//    // store the location as the "best effort"
//    self.bestEffortAtLocation = newLocation;
//    // test the measurement to see if it meets the desired accuracy
//    //
//    // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
//    // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
//    // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
//    //
//    if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
//      // we have a measurement that meets our requirements, so we can stop updating the location
//      //
//      // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
//      //
//      // DLog(@"self.bestEffortAtLocation    %@", self.bestEffortAtLocation);
//      
//      // [self.addressDelegate fetchCurrentLocationAddress:self.bestEffortAtLocation.coordinate];
//      [self change:newLocation];
//      [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
//      // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
//      //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
//    }
//  }
//  // update the display with the new location data
//  
//}
//
//
//



- (BOOL) locationServicesAvailable {
  return [[INTULocationManager sharedInstance] locationServicesAvailable];
}
+ (BOOL)needLocation{
  NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
  NSNumber *coordinatelatitude = [pref objectForKey:@"coordinatelatitude"];
  NSNumber *coordinatelongitude = [pref objectForKey:@"coordinatelongitude"];
 
  
  if ([coordinatelatitude integerValue] == 0 && [coordinatelongitude integerValue] == 0) {
    return YES;
  }
  else {
    
    NSNumber *lastlocatingtime = [pref objectForKey:@"lastlocatingtime"];

            NSNumber *timer  = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    
    if (fabs([lastlocatingtime doubleValue] - [timer doubleValue]) > 60) {
      return YES;
    }
    
    return NO;
  }
}
+ (CLLocationCoordinate2D)currentCoordinate {
 NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
 NSNumber *coordinatelatitude = [pref objectForKey:@"coordinatelatitude"];
 NSNumber *coordinatelongitude = [pref objectForKey:@"coordinatelongitude"];
 
 CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(coordinatelatitude.doubleValue, coordinatelongitude.doubleValue);
 
 return coordinate;
 }
//
//
//
//- (void)updateCurrentCoordinate:(CLLocationCoordinate2D)coordinate {
//  NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
//  
//  
//  [pref setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"coordinatelatitude"];
//  [pref setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"coordinatelongitude"];
//  [pref synchronize];
//}
//-(void)change:(CLLocation *)newLocation{
//  
//  
//  
//  //22.540681,=114.061324
//  //CLLocationCoordinate2D coordinate;
//  //coordinate.latitude =  22.540681;
//  //coordinate.longitude = 114.061324;
//  //CLLocation *newLocation=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude: coordinate.longitude];
//  CLGeocoder *geocoder=[[CLGeocoder alloc] init];
//  [geocoder reverseGeocodeLocation:newLocation
//                 completionHandler:^(NSArray *placemarks,
//                                     NSError *error)
//   {
//     if (placemarks.count > 0) {
//       CLPlacemark *placemark=[placemarks objectAtIndex:0];
//       DLog(@"我我的:%@\n country:%@\n postalCode:%@\n ISOcountryCode:%@\n ocean:%@\n inlandWater:%@\n locality:%@\n subLocality:%@ \n administrativeArea:%@\n subAdministrativeArea:%@\n thoroughfare:%@\n subThoroughfare:%@\n",
//            placemark.name,
//            placemark.country,
//            placemark.postalCode,
//            placemark.ISOcountryCode,
//            placemark.ocean,
//            placemark.inlandWater,
//            placemark.administrativeArea,
//            placemark.subAdministrativeArea,
//            placemark.locality,
//            placemark.subLocality,
//            placemark.thoroughfare,
//            placemark.subThoroughfare);
//       NSString *address = placemark.name;
//       
//       
//       NSString *locality = placemark.locality;
//       
//       NSMutableArray *citys = [CityHelper allCityNative];
//       
//       
//       if ([self.addressDelegate respondsToSelector:@selector(loadCurrentAddressString:)]) {
//         [self.addressDelegate loadCurrentAddressString:address];
//       }
//       
//       if ([self.coordinateDelegate respondsToSelector:@selector(loadCurrentCoordinate:)]) {
//         [self.coordinateDelegate loadCurrentCoordinate:newLocation.coordinate];
//       }
//       
//       
//       BOOL isHave = NO;
//       if (placemark) {
//         for (NSDictionary *aCity in citys) {
//           NSString *cityName = [aCity valueForKey:@"name"];
//           if ([locality rangeOfString:cityName].location != NSNotFound) {
//             self.currentCity = aCity;
//             isHave = YES;
//             [CityHelper selectCurrentCity:[[City alloc] initWithDictionary:aCity]];
//             [self updateCurrentCoordinate:newLocation.coordinate];
//             
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"cacheCategoyDataFromInternet" object:nil userInfo:nil];
//             
//             
//             
//             if ([self.addressDelegate respondsToSelector:@selector(loadCurrentAddress:)]) {
//               [self.addressDelegate loadCurrentAddress:aCity];
//             }
//             break;
//           }
//           //break;
//         }
//         
//         
//         
//         if (isHave == NO) {
//           for (NSDictionary *aCity in citys) {
//             NSString *cityName = [aCity valueForKey:@"pyf"];
//             
//             if ([address rangeOfString:cityName].location != NSNotFound) {
//               
//               self.currentCity = aCity;
//               isHave = YES;
//               
//               if ([self.addressDelegate respondsToSelector:@selector(loadCurrentAddress:)]) {
//                 [self.addressDelegate loadCurrentAddress:aCity];
//               }
//               
//               
//               
//               break;
//             }
//             break;
//           }
//         }
//         
//         
//         if (isHave == NO) {
//           for (NSDictionary *aCity in citys) {
//             NSString *cityName = [aCity valueForKey:@"pyf"];
//             
//             if ([address rangeOfString:cityName].location != NSNotFound) {
//               // DLog(@"%@ hahah",cityName);
//               self.currentCity = aCity;
//               isHave = YES;
//               //这里会产生bug，目前还不知道问题
//               if ([self.addressDelegate respondsToSelector:@selector(loadCurrentAddress:)]) {
//                 [self.addressDelegate loadCurrentAddress:aCity];
//               }
//             }
//             break;
//           }
//         }
//       }
//     }
//   }];
//  
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//  // The location "unknown" error simply means the manager is currently unable to get the location.
//  // We can ignore this error for the scenario of getting a single location fix, because we already have a
//  // timeout that will stop the location manager to save power.
//  if ([error code] != kCLErrorLocationUnknown) {
//    [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
//  }
//}
//
//
//
//- (void)stopUpdatingLocation:(NSString *)state {
//  //self.stateString = state;
//  // [self.tableView reloadData];
//  [self.locationManager stopUpdatingLocation];
//  //self.bestEffortAtLocation = nil;
//  // self.locationManager.delegate = nil;
//  
//  //UIBarButtonItem *resetItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", @"Reset") style:UIBarButtonItemStyleBordered target:self action:@selector(reset)] autorelease];
//  // [self.navigationItem setLeftBarButtonItem:resetItem animated:YES];;
//}
@end
