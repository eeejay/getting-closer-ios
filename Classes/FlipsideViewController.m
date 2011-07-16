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

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate, navigationBar, webView;


- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *documentsDirectory = [AssetManager DocumentsPath];
    self.view.backgroundColor = [UIColor blackColor];
	webView.opaque = NO;
	webView.backgroundColor = [UIColor clearColor];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"about.html"];
	NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:NO];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
	
#ifdef DIAGNOSTICS
	UINavigationItem *navigationItem = [navigationBar.items objectAtIndex:0];
	UIBarButtonItem *diagButton = [[UIBarButtonItem alloc] initWithTitle:@"Diagnostics"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(showDiagnostics)];
	navigationItem.rightBarButtonItem = diagButton;
	[diagButton release];
#endif
}


- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (void)showDiagnostics {
	SpotManager *spotManager = [self.delegate flipsideViewControllerNeedSpotManager:self];
	DiagnosticsViewController *diagnosticsController =
	[[DiagnosticsViewController alloc] initWithNibAndSpot:@"DiagnosticsViewController" spotManager:spotManager];
	diagnosticsController.delegate = self;
	
	[self presentModalViewController:diagnosticsController animated:YES];
	
	[diagnosticsController release];
}

- (void)diagnosticsViewControllerDidFinish:(DiagnosticsViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	navigationBar = nil;
    [super dealloc];
}


@end
