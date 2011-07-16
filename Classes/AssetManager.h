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
#import "Checksum.h"
#import "SoundSpot.h"
#import "SoundSpotPoint.h"
#import "DownloadHelper.h"

@class AssetManager;
@protocol AssetManagerDelegate <NSObject>

@optional
- (void)startedTrack:(NSInteger)trackNum:(NSInteger)totalTracks;
- (void)completedSync;
- (void)progressUpdated:(double)progress;
- (void)soundSpotIsReady:(SoundSpot *)soundSpot;
- (void)syncError:(NSString *)message;
@end


@interface AssetManager : NSObject {	
	NSString *_filePath;
	NSOutputStream *_fileStream;
	NSMutableDictionary *_needed_tracks;
	NSString *_current_track;
	NSMutableData *_json_data;
	NSMutableDictionary *_assets;
	CLLocation *_location;
	DownloadHelper *downloadHelper;
	

	long totalTrackNum;
	int totalTrackSize;
	int gotSoFar;
	double progress;
	
	
	id <AssetManagerDelegate> delegate;
}

- (void)startSync:(CLLocation *)location;
+ (NSString *)DocumentsPath;

@property (nonatomic, assign) id <AssetManagerDelegate> delegate;
@property (readonly) long currentTrackNum;
@property (readonly) long totalTrackNum;
@property (readonly) double progress;

@end
