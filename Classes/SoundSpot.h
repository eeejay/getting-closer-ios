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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import "Coordinates.h"

enum {
	SPOT_TIME_APPLICATION,
	SPOT_TIME_PROXIMITY,
	SPOT_TIME_ABSOLUTE,
} typedef SpotTiming;

@interface SoundSpot : NSObject <AVAudioPlayerDelegate> {
	NSString *filePath;
	NSString *name;
	AVAudioPlayer *audioPlayer;
	CLLocationDistance radius;
	CLLocationDistance currentDistance;
	SpotTiming timingMode;
	BOOL loop;
	BOOL hasPlayed;
	double startVolume;
}

- (id)initWithSettings:(NSDictionary *)settings;
- (void) setDeviceLocation:(CLLocation *)deviceLocation;

@property (nonatomic, assign) double volume;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) double startVolume;
@property (nonatomic, readonly) BOOL loop;
@property (nonatomic, readonly) SpotTiming timingMode;
@property (nonatomic, assign) CLLocationDistance currentDistance;
@property CLLocationDistance radius;
@property (nonatomic, readonly) id <MKAnnotation> annotation;

@end
