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

@class FancyLocationManager;

@protocol FancyLocationManagerDelegate <NSObject>

@optional

- (void)locationManager:(FancyLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)fancyLocation;

- (void)locationManager:(FancyLocationManager *)manager
	   didFailWithError:(NSError *)error;

@end


@interface FancyLocationManager : CLLocationManager {
	NSArray *waypoints;
	NSTimer *timer;
	NSInteger nextWayPoint;
	CLLocation *curPos;
}

@property(assign, nonatomic) id<FancyLocationManagerDelegate> delegate;

@end
