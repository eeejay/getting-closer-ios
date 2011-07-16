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

#import "SoundSpotLine.h"


@implementation SoundSpotLine

@synthesize annotation;

+ (SoundSpotLine *)lineWithSettings:(NSDictionary *)settings lineCoords:(NSArray *)coords {
	SoundSpotLine *soundSpotLine = [[SoundSpotLine alloc] initWithSettings:settings];
	
	[soundSpotLine autorelease];
	
	[soundSpotLine setLine:coords];
	
	return soundSpotLine;	
}

- (void)setLine:(NSArray *)coords {
	NSMutableArray *line_coords = [NSMutableArray array];
	CLLocationCoordinate2D *coords_2d = malloc(sizeof(CLLocationCoordinate2D) * [coords count]);
	int i = 0;

	for (NSArray *pair in coords) {
		CLLocationDegrees lon = [[pair objectAtIndex:0] doubleValue];
		CLLocationDegrees lat = [[pair objectAtIndex:1] doubleValue];

		coords_2d[i] = CLLocationCoordinate2DMake(lat, lon);

		[line_coords addObject:[[Coordinates alloc] initWithCoords:lon:lat]];
		i++;
	}
	lineCoordinates = [line_coords retain];
	annotation = [[MKPolyline polylineWithCoordinates:coords_2d count:[coords count]] retain];
	annotation.title = self.name;
	NSLog(@"pointline: %d", [coords count]);
	free(coords_2d);
}

- (void) setDeviceLocation:(CLLocation *)deviceLocation {
	Coordinates *ourLocation = [Coordinates withLocation:deviceLocation];
	CLLocationDistance newDistance = [ourLocation distanceToLinestring:lineCoordinates];
	NSLog(@"%@: %f", name, newDistance);
	self.currentDistance = newDistance;
}

- (void)dealloc {
	[lineCoordinates release];
	[annotation release];
	[super dealloc];
}


@end
