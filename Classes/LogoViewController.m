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

#import "LogoViewController.h"


@implementation LogoViewController
@synthesize animated;

+ (LogoViewController *)logoController {
	LogoViewController *obj = [[LogoViewController alloc] initWithNibName:@"LogoView" bundle:nil];
	[obj autorelease];
	return obj;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

- (void)startAnimating {
	CGAffineTransform transform = self.view.transform;
	transform = CGAffineTransformScale(transform, 1.0, 0.9);
	transform = CGAffineTransformTranslate(transform, -2, -4);
	[UIView animateWithDuration:1.0 delay:0.0
							options:UIViewAnimationOptionBeginFromCurrentState|
									UIViewAnimationOptionRepeat|
									UIViewAnimationOptionAutoreverse|
									UIViewAnimationOptionCurveEaseInOut|
									UIViewAnimationOptionAllowUserInteraction
							animations:^{
								self.view.transform = transform;
							}
					 completion:nil];
	animated = YES;
}

- (void)stopAnimating {
	[UIView animateWithDuration:0.5 delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState|
								UIViewAnimationOptionCurveEaseInOut|
								UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.view.transform = CGAffineTransformIdentity;
					 }
					 completion:nil];
	animated = NO;
}

- (void)dealloc {
    [super dealloc];
}


@end
