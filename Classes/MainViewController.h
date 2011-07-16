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
#import "SoundSpot.h"
#import "SpotManager.h"
#import "ProgressViewControler.h";
#import "LogoViewController.h";

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, SpotManagerDelegate> {
	UIButton *playPauseButton;
	UIButton *infoButton;
	UIImage *playBtnBG;
	UIImage *pauseBtnBG;
	UILabel *syncError;
	UIImageView  *loading;
	ProgressViewControler *progressView;
	LogoViewController *logoView;
	
	SpotManager *spotManager;
}

- (IBAction)showInfo;
- (IBAction)playPausePressed;

@property (nonatomic, retain) SpotManager *spotManager;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIImageView *loading;
@property (nonatomic, retain) IBOutlet UILabel *syncError;
@end
