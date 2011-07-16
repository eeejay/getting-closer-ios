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
#import "SoundSpot.h"
#import "FancyLocationManager.h"
#import "AssetManager.h"

enum {
	NONE = 0,
	SYNCING,
	DONE_SYNCING,
	STARTED,
	STOPPED,
	SUSPENDED
} typedef SpotManagerState;

@class SpotManager;

@protocol SpotManagerDelegate <NSObject>

@optional
- (void)stateChanged:(SpotManagerState)toState:(SpotManagerState)fromState;
- (void)startedTrack:(NSInteger)trackNum:(NSInteger)totalTracks;
- (void)progressUpdated:(double)progress;
- (void)syncError:(NSString *)message;
- (void)intensityUpdated:(double)intensity;
@end

@interface SpotManager : NSObject <FancyLocationManagerDelegate, AssetManagerDelegate> {
	NSMutableArray *soundSpots;
	FancyLocationManager *locationManager;
	AssetManager *assetManager;
	BOOL overrideLocation;
	BOOL inBackground;
	NSTimer *suspendTimer;
	UIBackgroundTaskIdentifier bgTask;

	id <SpotManagerDelegate> delegate;
	SpotManagerState state;
}

- (void)addSpot:(SoundSpot *)soundSpot;
- (void)startSync;
- (void)start;
- (void)stop;
- (void)changeLocation:(CLLocation *)newLocation;

@property (nonatomic, retain) NSMutableArray *soundSpots;
@property (nonatomic, retain) FancyLocationManager *locationManager;
@property (nonatomic, retain) AssetManager *assetManager;
@property (nonatomic, assign) id <SpotManagerDelegate> delegate;
@property (nonatomic, assign) SpotManagerState state;
@property (nonatomic, assign) BOOL overrideLocation;
@property (nonatomic, assign) BOOL inBackground;

@end
