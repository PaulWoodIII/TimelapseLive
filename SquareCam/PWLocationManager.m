//
//  PWLocationManager.m
//  SquareCam 
//
//  Created by Paul Wood on 9/12/12.
//
//

#import "PWLocationManager.h"

NSString *const kLocationManagerStartedNotificationName = @"kLocationManagerStartedNotificationName";
NSString *const kLocationManagerUpdateNotificationName = @"kLocationManagerUpdateNotificationName";
NSString *const kLocationManagerEndedNotificationName = @"kLocationManagerEndedNotificationName";
NSString *const kLocationManagerErrorNotificationName = @"kLocationManagerErrorNotificationName";

@interface PWLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, retain, readwrite) CLLocationManager *manager;
@property (nonatomic, assign, getter=isUpdatingLocation) BOOL updatingLocation;
@end


@implementation PWLocationManager

+ (id)sharedInstance {
    static PWLocationManager *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[PWLocationManager alloc] init];
    });
    
    return __sharedInstance;
}

-(id) init {
	if (! (self = [super init]))
		return nil;
    
	// create and configure the location manager
	_manager = [[CLLocationManager alloc] init];
	_manager.delegate = self;
	_manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // how much accuracy do we want before sending out notifications?
    _horizontalAccuracyThreshold = 100.0f;       // ~ 1 city block
    
    // how old of a cached coordinate are we willing to deal with?
    _timestampAccuracyThreshold = 10.0f;         // 10 seconds
    
    // kill location search after some time
    _accuracySearchTimeInterval = 30.0f;         // 30 secs
	
	return self;
}

#pragma mark Methods for grabbing location
-(void) pingLocation {
	
	if ([CLLocationManager locationServicesEnabled])
	{
        if (! self.updatingLocation)
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerStartedNotificationName object:nil];
        
		[self.manager startUpdatingLocation];
        self.updatingLocation = YES;
        
        // turn of GPS after some time
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, self.accuracySearchTimeInterval * NSEC_PER_SEC);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            [self stopLocation];
        });
	}
}

-(void) stopLocation {
    
    if (self.updatingLocation)
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerEndedNotificationName object:nil];
    
	[self.manager stopUpdatingLocation];
    self.updatingLocation = NO;
}

#pragma mark CLLocationManagerDelegate methods
-(void) locationManager:(CLLocationManager *)theManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"%@", newLocation);
	
	if (newLocation.horizontalAccuracy <= self.horizontalAccuracyThreshold && [newLocation.timestamp timeIntervalSinceNow] >= -self.timestampAccuracyThreshold) {
		[self stopLocation];
	} else {
		return ;
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerUpdateNotificationName object:nil];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	// let all interested parties know that we failed to find a location
	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerErrorNotificationName
														object:nil
													  userInfo:@{@"error": error}];
}

@end
