/* Getting Closer (http://getting-closer.org)
 * Copyright (C) 2010 Eitan Isaacson <eitan@monotonous.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "SpotManager.h"

#define APP_TIMEOUT 1800

@implementation SpotManager

@synthesize soundSpots, locationManager, delegate, state, assetManager, overrideLocation;

- (id)init {
	self = [super init];

	soundSpots = [[NSMutableArray alloc] init];

	self.assetManager = [[AssetManager alloc] init];
	self.assetManager.delegate = self;

	locationManager = [[FancyLocationManager alloc] init];
	locationManager.delegate = self;
	
	state = NONE;
	
	bgTask = UIBackgroundTaskInvalid;
	
	suspendTimer = nil;
	
	return self;
}

- (void)changeState:(SpotManagerState)toState {
	SpotManagerState oldState = state;
	state = toState;
	
	if ([delegate respondsToSelector:@selector(stateChanged::)])
		[delegate stateChanged:state:oldState];
}

- (void)startSync {
	[self changeState:SYNCING];

	locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	[locationManager startUpdatingLocation];
}

- (void)addSpot:(SoundSpot *)soundSpot
{
	[soundSpots addObject:soundSpot];
}

- (void)start
{
	locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
	[locationManager startUpdatingLocation];

	[self changeState:STARTED];
}

- (void)_stop {
	[locationManager stopUpdatingLocation];
	
	for (SoundSpot *spot in soundSpots)
		spot.volume = 0;
}

- (void)stop
{
	[self _stop];
	[self changeState:STOPPED];
}

- (void)locationManager:(FancyLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"SpotManager.didUpdateToLocation %f %f %f", newLocation.horizontalAccuracy, locationManager.desiredAccuracy, kCLLocationAccuracyBest);

	if (state == SYNCING) {
		NSLog(@"Starting to sync with location: %f %f", newLocation.coordinate.longitude, newLocation.coordinate.latitude);
		[locationManager stopUpdatingLocation];
		[assetManager startSync:newLocation];
		return;
	}

	if (!overrideLocation)
		[self changeLocation:newLocation];
}

- (void)changeLocation:(CLLocation *)newLocation {
	double intensity = 0;
	for (SoundSpot *spot in soundSpots) {
		[spot setDeviceLocation:newLocation];
		intensity = MAX(intensity, spot.volume);
	}

	if ([delegate respondsToSelector:@selector(intensityUpdated:)])
		[delegate intensityUpdated:intensity];

}

- (void)suspend {
}

- (void)suspend:(NSTimer *)aTimer {
	[self _stop];
	[self changeState:SUSPENDED];
	[suspendTimer release];
	suspendTimer = nil;
}

- (void)enterBackground {
	if (state == SYNCING) {
		UIApplication* app = [UIApplication sharedApplication];
		bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				NSLog(@"Expired!");
				[app endBackgroundTask:bgTask];
				bgTask = UIBackgroundTaskInvalid;
			});
		}];
	} else if (state == STARTED) {
		NSLog(@"Entering background, starting suspend timer.");
		suspendTimer = [NSTimer scheduledTimerWithTimeInterval:APP_TIMEOUT target:self selector:@selector(suspendApp:) userInfo:nil repeats:NO];
		[suspendTimer retain];
	}
}

- (void)enterForeground {
	if (state == SUSPENDED)
		[self start];
	if (suspendTimer != nil) {
		[suspendTimer invalidate];
		[suspendTimer release];
		suspendTimer = nil;
	}
}

- (void)setInBackground:(BOOL)inbg {
	if (inbg) {
		[self enterBackground];
	} else {
		[self enterForeground];
	}
	inBackground = inbg;
}

- (BOOL) inBackground {
	return inBackground;
}

/* AssetManager delegate methods */
- (void)startedTrack:(NSInteger)trackNum:(NSInteger)totalTracks {
	if ([delegate respondsToSelector:@selector(startedTrack::)])
		[delegate startedTrack:trackNum:totalTracks];
}

- (void)completedSync {
	[self changeState:DONE_SYNCING];
	if (bgTask != UIBackgroundTaskInvalid) {
		UIApplication *app = [UIApplication sharedApplication];
		[app endBackgroundTask:bgTask];
		bgTask = UIBackgroundTaskInvalid;
	}
	
	if (!self.inBackground)
		[self start];
	else
		[self changeState:SUSPENDED];
}

- (void)progressUpdated:(double)progress {
	if ([delegate respondsToSelector:@selector(progressUpdated:)])
		[delegate progressUpdated:progress];	
}

- (void)soundSpotIsReady:(SoundSpot *)soundSpot {
	[self addSpot:soundSpot];
}

- (void)syncError:(NSString *)message {
	if ([delegate respondsToSelector:@selector(syncError:)])
		[delegate syncError:message];	
}

- (void)dealloc {
	[soundSpots release];
	[locationManager release];
    [super dealloc];
}


@end
