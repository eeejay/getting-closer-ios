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

#import "SoundSpotArea.h"


@implementation SoundSpotArea

@synthesize annotation;

+ (SoundSpotArea *)areaWithSettings:(NSDictionary *)settings areaCoords:(NSArray *)coords {
	SoundSpotArea *soundSpotArea = [[SoundSpotArea alloc] initWithSettings:settings];
	
	[soundSpotArea autorelease];
	
	[soundSpotArea setArea:coords];
	
	return soundSpotArea;	
}

- (void)setArea:(NSArray *)coords {
	NSMutableArray *line_coords = [NSMutableArray array];
	NSArray *coordinates = [coords objectAtIndex:0];
	CLLocationCoordinate2D *coords_2d = malloc(sizeof(CLLocationCoordinate2D) * [coordinates count]);
	int i = 0;
	
	
	for (NSArray *pair in coordinates) {
		CLLocationDegrees lon = [[pair objectAtIndex:0] doubleValue];
		CLLocationDegrees lat = [[pair objectAtIndex:1] doubleValue];
		
		coords_2d[i] = CLLocationCoordinate2DMake(lat, lon);
		
		[line_coords addObject:[[Coordinates alloc] initWithCoords:lon:lat]];
		i++;
	}
	areaCoordinates = [line_coords retain];
	annotation = [[MKPolygon polygonWithCoordinates:coords_2d count:[coordinates count]] retain];
	annotation.title = self.name;
	NSLog(@"polygon: %d", [coordinates count]);
	free(coords_2d);
}

- (void) setDeviceLocation:(CLLocation *)deviceLocation {
	Coordinates *ourLocation = [Coordinates withLocation:deviceLocation];
	CLLocationDistance newDistance = [ourLocation distanceToPolygon:areaCoordinates];
	NSLog(@"%@: %f", name, newDistance);
	self.currentDistance = newDistance;
}

- (void)dealloc {
	[areaCoordinates release];
	[annotation release];
	[super dealloc];
}

@end
