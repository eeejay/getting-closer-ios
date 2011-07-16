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

#import "DiagnosticsViewController.h"

#define GMAP_ANNOTATION_SELECTED @"gMapAnnontationSelected"

@implementation DiagnosticsViewController

@synthesize delegate, spotView, overrideSwitch;


- (id)initWithNibAndSpot:(NSString *)nibNameOrNil spotManager:(SpotManager *)spotManager {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nil])) {
     	_spotManager = [spotManager retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	for (SoundSpot *spot in _spotManager.soundSpots)
		if ([spot isKindOfClass:[SoundSpotPoint class]])
			[spotView addAnnotation:spot.annotation];
		else
			[spotView addOverlay:(id <MKOverlay>)spot.annotation];
	
	locationAnnotation = [[MKPointAnnotation alloc] init];

	if ([_spotManager.soundSpots count] > 0)
	{
		CLLocationDegrees minLat, maxLat, minLon, maxLon;
		minLat = minLon = maxLat = maxLon = 0;
		for (SoundSpot *spot in _spotManager.soundSpots)
		{
			NSLog (@"minLat: %f > %f", spot.annotation.coordinate.latitude, minLat);
			if (minLat == 0.0 || spot.annotation.coordinate.latitude < minLat)
				minLat = spot.annotation.coordinate.latitude;
			if (minLon == 0.0 || spot.annotation.coordinate.longitude < minLon)
				minLon = spot.annotation.coordinate.longitude;
			if (maxLat == 0.0 || spot.annotation.coordinate.latitude > maxLat)
				maxLat = spot.annotation.coordinate.latitude;
			if (maxLon == 0.0 || spot.annotation.coordinate.longitude > maxLon)
				maxLon = spot.annotation.coordinate.longitude;		
		}
		NSLog (@"%f %f %f %f", minLat, minLon, maxLat, maxLon);
		MKCoordinateRegion region;
		MKCoordinateSpan span;
		CLLocationCoordinate2D center;
		center.latitude = (minLat + maxLat)/2;
		center.longitude = (minLon + maxLon)/2;
		if ([_spotManager.soundSpots count] > 1)
		{
			span.latitudeDelta = maxLat - minLat;
			span.longitudeDelta = maxLon - minLon;
		} else if ([_spotManager.soundSpots count] == 1)
		{
			span.latitudeDelta = 0.002;
			span.longitudeDelta = 0.002;
		}
		region.span = span;
		region.center = center;
		spotView.region = region;
	}

#if TARGET_IPHONE_SIMULATOR
	spotView.showsUserLocation = NO;
#else
	spotView.showsUserLocation = YES;
#endif
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	_spotManager.delegate = nil;
	[_spotManager release];
	[spotView release];
	[overrideSwitch release];
    [super dealloc];
}

- (void)changeLocation:(CLLocationCoordinate2D)coordinate {
	CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	[_spotManager changeLocation:location];
	[location release];
}

- (IBAction)done {
	[self.delegate diagnosticsViewControllerDidFinish:self];	
}

- (IBAction)override {
	NSLog(@"override");
	spotView.showsUserLocation = !overrideSwitch.on;
	_spotManager.overrideLocation = overrideSwitch.on;
	if (overrideSwitch.on) {
		locationAnnotation.coordinate = spotView.centerCoordinate;
		[spotView addAnnotation:locationAnnotation];
		[self changeLocation:locationAnnotation.coordinate];
	} else {
		[spotView removeAnnotation:locationAnnotation];
	}
}

- (void)updatedLocation:(CLLocation *)newLocation
{
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	NSLog(@"viewForAnnotaion %@", annotation.description);
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	NSString *identifier;
	if (annotation == locationAnnotation)
		identifier = @"location";
	else
		identifier = @"point";

	MKAnnotationView *anView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if (anView != nil) {
		anView.annotation = annotation;
		return anView;
	}

	if (annotation == locationAnnotation) {
		anView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		[(MKPinAnnotationView *)anView setPinColor:MKPinAnnotationColorGreen];
		[(MKPinAnnotationView *)anView setAnimatesDrop:YES];
		anView.draggable = YES;
	} else if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	} else {
		anView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
	}

	return anView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	NSLog(@"polyline? %@", overlay.title);
	MKOverlayPathView *oView = nil;
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		oView = [[MKPolylineView alloc] initWithPolyline:overlay];
	} else if ([overlay isKindOfClass:[MKPolygon class]]) {
		NSLog(@"making polygon");
		oView = [[MKPolygonView alloc] initWithPolygon:overlay];
	}

	oView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
	oView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.6];
	oView.lineWidth = 6;
	
	[oView autorelease];

	return oView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (newState != MKAnnotationViewDragStateEnding)
		return;

	[self changeLocation:annotationView.annotation.coordinate];
}

@end
