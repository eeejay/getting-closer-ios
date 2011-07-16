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
#import "Coordinates.h"
#import <math.h>
#import <float.h>

@implementation Coordinates

static double F = (1.0 - 1.0 / 298.257223563)*(1.0 - 1.0 / 298.257223563);
static double EQ_RADIUS = 6378137.0;

+ (double)geocentricLatitude:(double)geographic_latitude {
  return atan(tan(geographic_latitude) * F);
}

+ (double)geographicLatitude:(double)geocentric_latitude {
  return atan(tan(geocentric_latitude) / F);
}

+ (Coordinates *)withCentroid:(NSArray *)coords {
	double x = 0.0;
	double y = 0.0;
	double z = 0.0;
	NSInteger len = [coords count];
	for (Coordinates *coordinate in coords) {
		x += coordinate.x;
		y += coordinate.y;
		z += coordinate.z;
	}
	Coordinates *coord = [[Coordinates alloc] initWithXYZ:x/len:y/len:z/len];
	
	[coord autorelease];
	
	return coord;
}

+ (Coordinates *)withLocation:(CLLocation *)location {
	Coordinates *coords = [[Coordinates alloc] initWithCoords:location.coordinate.longitude:location.coordinate.latitude];
	
	[coords autorelease];
	
	return coords;
}

+ (Coordinates *)withIntersection:(Coordinates *)geo1:(Coordinates *)geo2:(Coordinates *)geo3:(Coordinates *)geo4 {
  Coordinates *geo_cross1 = [Coordinates withCrossNormalize:geo1:geo2];
  Coordinates *geo_cross2 = [Coordinates withCrossNormalize:geo3:geo4];

  return [Coordinates withCrossNormalize:geo_cross1:geo_cross2];
}

+ (Coordinates *)withAntipode:(Coordinates *)geo {
  return [Coordinates withScale:geo scale:-1.0];
}

+ (Coordinates *)withScale:(Coordinates *)geo scale:(double)scale {
  double x = [geo x] * scale;
  double y = [geo y] * scale;
  double z = [geo z] * scale;
  Coordinates *coords = [[Coordinates alloc] initWithXYZ:x:y:z];

  [coords autorelease];

  return coords;
}

+ (Coordinates *)withCrossNormalize:(Coordinates *)geo1:(Coordinates *)geo2 {
  
  double x = ([geo1 y] * [geo2 z]) - ([geo1 z] * [geo2 y]);
  double y = ([geo1 z] * [geo2 x]) - ([geo1 x] * [geo2 z]);
  double z = ([geo1 x] * [geo2 y]) - ([geo1 y] * [geo2 x]);
  double L = sqrt(x*x + y*y + z*z);

  Coordinates *coords = [[Coordinates  alloc] initWithXYZ:x/L:y/L:z/L];

  [coords autorelease];

  return coords;
}

+ (double)radiansToMeters:(double)rad {
  return rad * EQ_RADIUS;
}

+ (double)metersToRadians:(double)m {
  return m / EQ_RADIUS;
}


- (Coordinates *)initWithCoords:(double)lon:(double)lat {
  Coordinates *s = [self init];
  double theta = lon * M_PI / 180.0;
  double rlat = [Coordinates geocentricLatitude:(lat * M_PI / 180)];
  double c = cos(rlat);
  _x = c * cos(theta);
  _y = c * sin(theta);
  _z = sin(rlat);

  return s;
}

- (Coordinates *)initWithXYZ:(double)x:(double)y:(double)z {
  Coordinates *s = [self init];
  
  _x = x;
  _y = y;
  _z = z;

  return s;
}

- (double)crossLength:(Coordinates *)b {
  double x = (_y * [b z]) - (_z * [b y]);
  double y = (_z * [b x]) - (_x * [b z]);
  double z = (_x * [b y]) - (_y * [b x]);

  return sqrt(x*x + y*y + z*z);
}

- (double)distanceRadians:(Coordinates *)b {
  return atan2([b crossLength:self], [b dot:self]);
}

- (double)distanceMeters:(Coordinates *)b {
  return [Coordinates radiansToMeters:[self distanceRadians:b]];
}

- (double)distanceToLineSegment:(Coordinates *)geo1:(Coordinates *)geo2 {
  Coordinates *p2 = [Coordinates withCrossNormalize:geo1:geo2];
  Coordinates *ip = [Coordinates withIntersection:geo1:geo2:self:p2];

  double d = [geo1 distanceMeters:geo2];
  double d1p = [geo1 distanceMeters:ip];
  double d2p = [geo2 distanceMeters:ip];

  if ((d > d1p) && (d >= d2p))
    return [self distanceMeters:ip];
  
  Coordinates *ip_antipode = [Coordinates withAntipode:ip];  
  d1p = [geo1 distanceMeters:ip_antipode];
  d2p = [geo2 distanceMeters:ip_antipode];

  if ((d > d1p) && (d >= d2p))
    return [self distanceMeters:ip_antipode];

  return MIN([geo1 distanceMeters:self], [geo2 distanceMeters:self]);
}

- (double)distanceToLinestring:(NSArray *)polyline {
  double d = DBL_MAX;
  int i;    

  for (i=0;i<[polyline count] - 1;i++) {
    Coordinates *l1 = [polyline objectAtIndex:i];
    Coordinates *l2 = [polyline objectAtIndex:i+1];
    double db = [self distanceToLineSegment:l1:l2];

    if (db < d)
      d = db;
  }

  return d;
  
}

- (BOOL)hitTest:(NSArray *)polygon {
  int i;
  int counter = 0;

  for (i=0;i<[polygon count] - 1;i++) {
    Coordinates *p1 = [polygon objectAtIndex:i];
    Coordinates *p2 = [polygon objectAtIndex:i+1];
    double p1x = [p1 x];
    double p1y = [p1 y];
    double p2x = [p2 x];
    double p2y = [p2 y];
    if (_y > MIN(p1y, p2y)) {
      if (_y <= MAX(p1y, p2y)) {
        if (_x <= MAX(p1x, p2x)) {
          if (p1y != p2y) {
            double xinters = (_y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x;
            if (p1x == p2x || _x <= xinters)
              counter++;
          }
        }
      }
    }
  }

  return (counter % 2 != 0);
}

- (double)distanceToPolygon:(NSArray *)polygon {
  if ([self hitTest:polygon])
    return 0.0;

  return [self distanceToLinestring:polygon];
}

- (double)x {
  return _x;
}

- (double)y {
  return _y;
}

- (double)z {
  return _z;
}

- (double)dot:(Coordinates *)b {
  return (_x * [b x]) + (_y * [b y]) + (_z * [b z]);
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationDegrees lat = [Coordinates geographicLatitude:atan2(_z, sqrt(_x*_x + _y*_y))] * 180.0 / M_PI;
	CLLocationDegrees lon = atan2(_y, _x) * 180.0 / M_PI;
	return CLLocationCoordinate2DMake(lat, lon);
}

@end