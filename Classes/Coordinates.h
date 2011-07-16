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


@interface Coordinates : NSObject {
  double _x;
  double _y;
  double _z;
}

+ (double)geocentricLatitude:(double)geographic_latitude;
+ (double)geographicLatitude:(double)geocentric_latitude;
+ (Coordinates *)withCentroid:(NSArray *)coords;
+ (Coordinates *)withIntersection:(Coordinates *)geo1:(Coordinates *)geo2:(Coordinates *)geo3:(Coordinates *)geo4;
+ (Coordinates *)withScale:(Coordinates *)geo scale:(double)scale;
+ (Coordinates *)withCrossNormalize:(Coordinates *)geo1:(Coordinates *)geo2;
+ (Coordinates *)withAntipode:(Coordinates *)geo;
+ (Coordinates *)withLocation:(CLLocation *)location;
+ (double)radiansToMeters:(double)rad;
+ (double)metersToRadians:(double)m;

- (Coordinates *)initWithCoords:(double)lon:(double)lat;
- (Coordinates *)initWithXYZ:(double)x:(double)y:(double)z;
- (double)distanceRadians:(Coordinates *)b;
- (double)distanceMeters:(Coordinates *)b;
- (double)distanceToLineSegment:(Coordinates *)geo1:(Coordinates *)geo2;
- (double)distanceToLinestring:(NSArray *)polyine;
- (BOOL)hitTest:(NSArray *)polygon;
- (double)distanceToPolygon:(NSArray *)polygon;
- (double)crossLength:(Coordinates *)b;
- (double)dot:(Coordinates *)b;

- (double)x;
- (double)y;
- (double)z;
- (CLLocationCoordinate2D)coordinate;


@end