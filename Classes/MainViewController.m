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

#import "MainViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController

@synthesize spotManager, playPauseButton, loading, infoButton, syncError;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
	
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	playBtnBG = [[UIImage imageNamed:@"play.png"] retain];
	pauseBtnBG = [[UIImage imageNamed:@"pause.png"] retain];
	
	spotManager = [[SpotManager alloc] init];
	spotManager.delegate = self;
	
	logoView = [[LogoViewController logoController] retain];
	CGRect f = logoView.view.frame;
	logoView.view.frame = CGRectMake(90, 108, f.size.width, f.size.height);
	[self.view addSubview:logoView.view];
	
	progressView = [[ProgressViewControler progressController] retain];
	f = progressView.view.frame;
	NSLog(@"view %@", progressView.view);
	progressView.view.frame = CGRectMake(86, 84, f.size.width, f.size.height);
	[self.view addSubview:progressView.view];
	
	[spotManager startSync];
	
	//[progressView.view setHidden:YES];
	//[logoView startAnimating];	

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (SpotManager *)flipsideViewControllerNeedSpotManager:(FlipsideViewController *)controller
{
	return spotManager;
}

- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	NSLog(@"show info");
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (void)enterForeground {
	NSLog(@"Entering foreground, invalidating suspend timer.");
	if (spotManager.state == STARTED)
		[logoView startAnimating];
/*	if (spotManager.state == SYNCING)
		[activityView startAnimating]; */
	spotManager.inBackground = NO;
}

- (void)enterBackground {
	if (spotManager.state == SYNCING) {
/*		[activityView stopAnimating]; */
	} else if (spotManager.state == STARTED) {
		[logoView stopAnimating];
	}
	spotManager.inBackground = YES;
}

- (void)appWillTerminate {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
	return TRUE;
}

- (BOOL)playPause {
	if (spotManager.state == STARTED) {
		[spotManager stop];
		return FALSE;
	} else {
		[spotManager start];
		return TRUE;
	}
}

- (void)playPausePressed {
	[self playPause];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    if (theEvent.type == UIEventTypeRemoteControl &&
		(theEvent.subtype == UIEventSubtypeRemoteControlPlay ||
		 theEvent.subtype == UIEventSubtypeRemoteControlPause ||
		 theEvent.subtype == UIEventSubtypeRemoteControlTogglePlayPause ||
		 theEvent.subtype == UIEventSubtypeRemoteControlStop)) {
			BOOL active = [self playPause];
			[[AVAudioSession sharedInstance] setActive:active error:nil];
	}
}

/* SpotManager delegate methods */

- (void)intensityUpdated:(double)intensity {
	NSLog(@"intensity updated: %f", intensity);
	CGFloat hue = 0.12777778;
	CGFloat saturation = intensity * 0.78;
	CGFloat brightness = 0.96;

	[UIView animateWithDuration:1 delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState|
								UIViewAnimationOptionCurveEaseInOut|
								UIViewAnimationOptionAllowUserInteraction
						animations:^{ 
							self.view.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
						}
					 completion:nil];
}

- (void)startedTrack:(NSInteger)trackNum:(NSInteger)totalTracks {
}

- (void)stateChanged:(SpotManagerState)toState :(SpotManagerState)fromState {
	switch (toState) {
		case SYNCING:
			playPauseButton.hidden = YES;
			infoButton.hidden = YES;
			NSLog(@"syncing!");
			logoView.view.hidden = YES;
			progressView.view.hidden = NO;
			loading.hidden = NO;
			break;
		case DONE_SYNCING:
			progressView.view.hidden = YES;
			loading.hidden = YES;
			break;
		case STARTED:
			dispatch_async(dispatch_get_main_queue(), ^{
				[logoView startAnimating];
			});
			[playPauseButton setImage:pauseBtnBG forState:UIControlStateNormal];
			playPauseButton.hidden = NO;
			infoButton.hidden = NO;
			logoView.view.hidden = NO;
			break;
		case STOPPED:
			[logoView stopAnimating];
			[playPauseButton setImage:playBtnBG forState:UIControlStateNormal];
			playPauseButton.hidden = NO;
			break;
		default:
			break;
	}
}

- (void)progressUpdated:(double)progress {
	progressView.progress = progress;
}

- (void)syncError:(NSString *)message
{
	syncError.hidden = NO;
	syncError.text = message;
	/* [activityView stopAnimating]; */
}


- (void)dealloc {
	[playBtnBG release];
	[pauseBtnBG release];
	[infoButton release];
	[playPauseButton release];
	[logoView release];
	[progressView release];
	
    [super dealloc];
}

@end
