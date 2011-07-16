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

#import <UIKit/UIKit.h>
#import "SpotManager.h"


@protocol DiagnosticsViewControllerDelegate;


@interface DiagnosticsViewController : UIViewController <MKMapViewDelegate> {
	SpotManager *_spotManager;
	MKMapView *spotView;
	UISwitch *overrideSwitch;
	SoundSpot *_selectedSpot;
	id <DiagnosticsViewControllerDelegate> delegate;
	MKPointAnnotation *locationAnnotation;
}

@property (nonatomic, assign) id <DiagnosticsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet MKMapView *spotView;
@property (nonatomic, retain) IBOutlet UISwitch *overrideSwitch;

- (IBAction)done;
- (IBAction)override;
- (id)initWithNibAndSpot:(NSString *)nibNameOrNil spotManager:(SpotManager *)spotManager;

@end


@protocol DiagnosticsViewControllerDelegate
- (void)diagnosticsViewControllerDidFinish:(DiagnosticsViewController *)controller;
@end