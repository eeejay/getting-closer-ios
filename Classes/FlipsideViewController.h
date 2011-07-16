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
#import "DiagnosticsViewController.h"
#import "AssetManager.h"

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController <DiagnosticsViewControllerDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
	UINavigationBar *navigationBar;
	UIWebView *webView;
	
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
- (IBAction)done;
- (IBAction)showDiagnostics;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
- (SpotManager *)flipsideViewControllerNeedSpotManager:(FlipsideViewController *)controller;
@end

