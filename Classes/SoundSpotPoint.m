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

#import "SoundSpotPoint.h"


@implementation SoundSpotPoint

@synthesize annotation;

+ (SoundSpotPoint *)pointWithSettings:(NSDictionary *)settings pointCoords:(NSArray *)coords {
	SoundSpotPoint *soundSpotPoint = [[SoundSpotPoint alloc] initWithSettings:settings];
	
	[soundSpotPoint autorelease];

	[soundSpotPoint setPoint:coords];
	
	return soundSpotPoint;
}

- (void)setPoint:(NSArray *)coords {
	CLLocationDegrees lon = [[coords	objectAtIndex:0] doubleValue];
	CLLocationDegrees lat = [[coords	objectAtIndex:1] doubleValue];
	
	location = [[[Coordinates alloc] initWithCoords:lon:lat] retain];
	annotation = [[MKPointAnnotation alloc] init];
	annotation.coordinate = location.coordinate;
	annotation.title = self.name;
}

- (void) setDeviceLocation:(CLLocation *)deviceLocation {
	Coordinates *ourLocation = [Coordinates withLocation:deviceLocation];
	CLLocationDistance newDistance = [location distanceMeters:ourLocation];
	NSLog(@"%@: %f", name, newDistance);
	self.currentDistance = newDistance;
}

- (void)dealloc {
	[location release];
	[super dealloc];
}

@end
