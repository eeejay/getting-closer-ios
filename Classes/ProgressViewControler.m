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

#import "ProgressViewControler.h"


@implementation ProgressViewControler
@synthesize clipper;

+ (ProgressViewControler *)progressController {
	ProgressViewControler *obj = [[ProgressViewControler alloc] initWithNibName:@"ProgressView" bundle:nil];
	[obj autorelease];
	return obj;
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }

	progress = 0;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 CGRect f = clipper.frame;
 fullWidth = f.size.width;
 clipper.frame = CGRectMake (f.origin.x,f.origin.y, 0 ,f.size.height);
}

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
	CGRect f = clipper.frame;
	clipper.frame = CGRectMake (f.origin.x,f.origin.y, 0 ,f.size.height);
	[UIView animateWithDuration:2.0 delay:0
						options:0
						animations:^{
							clipper.frame = f;
						}
						completion:NULL];
}

- (void)setProgress:(double)_progress {
	CGRect f = clipper.frame;
	[UIView animateWithDuration:0.5 delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState|
						UIViewAnimationOptionCurveEaseInOut|
						UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 clipper.frame = CGRectMake (f.origin.x,f.origin.y, _progress*fullWidth ,f.size.height);
					 }
					 completion:nil];
	
	progress = _progress;
}

-(double)progress {
	return progress;
}

- (void)dealloc {
    [super dealloc];
}


@end
