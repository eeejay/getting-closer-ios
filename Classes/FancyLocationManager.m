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

#import "FancyLocationManager.h"


@implementation FancyLocationManager
@dynamic delegate;

#if TARGET_IPHONE_SIMULATOR

#define INTERVAL 3
#define KMH 10.0

- (CLLocation *)getLocationAtIndex:(NSInteger)index
{
	NSArray *latLong = [(NSString *)[waypoints objectAtIndex:index] componentsSeparatedByString:@", "];
	
	CLLocationDegrees lat = [[latLong objectAtIndex:0] doubleValue];
	CLLocationDegrees lon = [[latLong objectAtIndex:1] doubleValue];
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];

	//[latLong release];
	
	return location;
}

- (void)fakeUpdate:(NSTimer *)aTimer
{
	CLLocation *pointB = [self getLocationAtIndex:nextWayPoint];
	
	CLLocationDistance fromAtoB = [curPos distanceFromLocation:pointB];
	double progression = (KMH * 1000.0 / 3600.0 * INTERVAL)/fromAtoB;
	double latDelta = (pointB.coordinate.latitude - curPos.coordinate.latitude)*progression;
	double lonDelta = (pointB.coordinate.longitude - curPos.coordinate.longitude)*progression;
	
	CLLocation *oldLocation = curPos;
	
	if (progression < 1.0)
	{
		curPos = [[CLLocation alloc] initWithLatitude:curPos.coordinate.latitude + latDelta
											longitude:curPos.coordinate.longitude + lonDelta];
	} else {
		curPos = [pointB retain];
		nextWayPoint = ([waypoints count] > nextWayPoint + 1) ? nextWayPoint + 1 : 0;
	}

	[self.delegate locationManager:self
			   didUpdateToLocation:curPos
					  fromLocation:oldLocation];
	
	//NSLog (@"update (%f, %f)", curPos.coordinate.latitude, curPos.coordinate.longitude);

	[oldLocation release];
	[pointB release];
	
}

- (id)init
{
	self = [super init];
	
	NSBundle* myBundle = [NSBundle mainBundle];
		
	waypoints = [[NSArray alloc] initWithContentsOfFile:
				 [myBundle pathForResource:@"FakeTrip" ofType:@"plist"]];

	NSLog (@"waypoints: %d", [waypoints count]);

	return self;
}

- (void)dealloc
{
	[waypoints release];
	[timer release];
	[super dealloc];
}

- (void)startUpdatingLocation
{
	curPos = [self getLocationAtIndex:0];
	nextWayPoint = 1;
	timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fakeUpdate:) userInfo:nil repeats:YES];
	[self fakeUpdate:timer];
	[timer retain];
}

#endif

@end
