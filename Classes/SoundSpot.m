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

#import "SoundSpot.h"
#import "AssetManager.h"
#include <math.h>

#define DEVICE_TIME_DELAY 1

@implementation SoundSpot

@synthesize name, radius, timingMode, loop, startVolume;

- (id)initWithSettings:(NSDictionary *)settings {
	self = [super init];
	
	name = [[settings objectForKey:@"name"] retain];
	filePath = [[settings objectForKey:@"filePath"] retain];
	radius = [[settings objectForKey:@"radius"] floatValue];
	startVolume = [[settings objectForKey:@"startVolume"] floatValue];
	timingMode = [[settings objectForKey:@"timingMode"] intValue];
	loop = [[settings objectForKey:@"loop"] boolValue];

	NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
	AVAudioPlayer *aPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url  error:NULL];
	audioPlayer = [aPlayer retain];
	[aPlayer release];
	audioPlayer.delegate = self;
	audioPlayer.volume = 0.0;
	
	if (loop)
		audioPlayer.numberOfLoops = -1;
	else
		audioPlayer.numberOfLoops = 0;
	
	NSLog(@"Looping :%d", self.loop);
	
	return self;	
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	NSLog(@"spot finished %d %@", flag, name);
}

- (void) setCurrentDistance:(CLLocationDistance)distance {
	/* Just entered radius, play again if we are not looping */
	if (distance <= radius && currentDistance > radius)
		hasPlayed = NO;	
	currentDistance = distance;
	double newVolume = (currentDistance < radius) ? (1.0 - (currentDistance/radius))*(1.0 - startVolume) + startVolume : 0.0;
	NSLog(@"volume: %f", newVolume);
	self.volume = newVolume;
}

- (CLLocationDistance) currentDistance {
	return currentDistance;
}

- (void) setDeviceLocation:(CLLocation *)deviceLocation {
 }

- (double)volume
{
	return audioPlayer.volume;
}

- (void)setVolume:(double)volume;
{
	if (volume <= 0)
		[audioPlayer pause];
	
	if (!audioPlayer.playing && hasPlayed && !self.loop)
		return;
	
	if (volume > 0 && !audioPlayer.playing)
	{
		NSLog(@"Starting %@", name);
		NSTimeInterval devTime = [audioPlayer deviceCurrentTime];

		if (timingMode == SPOT_TIME_ABSOLUTE) {
			audioPlayer.currentTime = fmod([[NSDate date] timeIntervalSince1970] + DEVICE_TIME_DELAY, audioPlayer.duration);
		} else if (timingMode == SPOT_TIME_APPLICATION) {
			audioPlayer.currentTime = fmod(devTime + DEVICE_TIME_DELAY, audioPlayer.duration);
		} else {
			audioPlayer.currentTime = 0;
		}

		[audioPlayer playAtTime:devTime + DEVICE_TIME_DELAY];
		
		hasPlayed = YES;
//		NSLog(@"Starting '%@' at %f dev time: %f", name, audioPlayer.currentTime, [audioPlayer deviceCurrentTime] - devTime);
	}
	
	audioPlayer.volume = volume;
}

- (void)dealloc {
	[filePath release];
	[audioPlayer release];
	[name release];
    [super dealloc];
}

- (id)annotation {
	return nil;
}

- (NSString *)identifier {
	return @"spot";
}

- (MKMapRect)boundingMapRect {
	return MKMapRectMake(0,0,0,0);
}

@end
