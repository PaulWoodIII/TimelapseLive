//
//  PWLocationManager.h
//  SquareCam 
//
//  Created by Paul Wood on 9/12/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kLocationManagerStartedNotificationName;
extern NSString *const kLocationManagerUpdateNotificationName;
extern NSString *const kLocationManagerEndedNotificationName;
extern NSString *const kLocationManagerErrorNotificationName;

@interface PWLocationManager : NSObject

@property (nonatomic, retain, readonly) CLLocationManager *manager;

 // how accurate of a coordinate do we require?
@property (nonatomic, assign) CLLocationAccuracy horizontalAccuracyThreshold;

// how old of coordinates are we willing to accept?
@property (nonatomic, assign) NSTimeInterval timestampAccuracyThreshold;

// how long are we willing to leave GPS turned on while we search for a location
@property (nonatomic, assign) NSTimeInterval accuracySearchTimeInterval;        

+ (id)sharedInstance;
- (void) pingLocation;
- (void) stopLocation;

@end

