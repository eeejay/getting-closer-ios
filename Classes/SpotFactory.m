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

#import "SpotFactory.h"
#import "SoundSpot.h"
#import "SoundSpotPoint.h"
#import "SoundSpotLine.h"
#import "SoundSpotArea.h"

@implementation SpotFactory

+ (id)spotFromGeoJson:(NSDictionary *)json_data asset:(NSString *)asset {
	NSString *geom_type = [[json_data objectForKey:@"geometry"] objectForKey:@"type"];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	NSDictionary *props = [json_data objectForKey:@"properties"];
	
	[settings setObject:asset forKey:@"filePath"];
	[settings setObject:[props valueForKey:@"name"] forKey:@"name"];
	[settings setObject:[props valueForKey:@"radius"] forKey:@"radius"];
	[settings setObject:[props valueForKey:@"start_volume"] forKey:@"startVolume"];
	[settings setObject:[props valueForKey:@"loop"] forKey:@"loop"];

	NSString *timing_mode = [props valueForKey:@"sync"];
	SpotTiming mode;
	
	if ([timing_mode compare:@"abs"] == NSOrderedSame)
		mode = SPOT_TIME_ABSOLUTE;
	else if ([timing_mode compare:@"prx"] == NSOrderedSame)
		mode = SPOT_TIME_PROXIMITY;
	else
		mode = SPOT_TIME_APPLICATION;
	
	
	[settings setObject:[NSNumber numberWithInt:mode] forKey:@"timingMode"];
	
	NSArray *coords = [[json_data objectForKey:@"geometry"] objectForKey:@"coordinates"];

	if ([geom_type compare:@"Point"] == NSOrderedSame)
		return [SoundSpotPoint pointWithSettings:settings pointCoords:coords];
	else if ([geom_type compare:@"LineString"] == NSOrderedSame)
		return [SoundSpotLine lineWithSettings:settings lineCoords:coords];
	else if ([geom_type compare:@"Polygon"] == NSOrderedSame)
		return [SoundSpotArea areaWithSettings:settings areaCoords:coords];
	else
		return nil;

}

@end
