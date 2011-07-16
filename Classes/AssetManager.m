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

#import "AssetManager.h"
#import "JSON/SBJsonParser.h"
#import "SpotFactory.h"

#ifdef EITAN
static NSString * defaultBaseUrl = @"http://staging.monotonous.org/device/eitan";
#else
#ifdef JENNY
static NSString * defaultBaseUrl = @"http://staging.monotonous.org/device/jenny";
#else
static NSString * defaultBaseUrl = @"http://staging.monotonous.org/device/gettingcloser";
#endif
#endif

@implementation AssetManager

@synthesize totalTrackNum, progress, delegate;

+ (NSString *)DocumentsPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (NSString *)AbsPath:(NSString *)fileName {
	NSString *documentsDirectory = [AssetManager DocumentsPath];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (NSString *) _trackDownloaded:(NSString *)remoteDigest
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *documentsDirectory = [AssetManager DocumentsPath];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", remoteDigest]];
	BOOL rv = NO;
	
	//return nil;

	if ([fileManager fileExistsAtPath:filePath])
	{
		NSString *fileSha1 = [Checksum getSha1:filePath];
		if ([fileSha1 isEqualToString:remoteDigest])
		{
			rv = YES;
		}
	}

	NSLog(@"Already downloaded %@? %@", filePath, rv ? @"yes" : @"no");

	if (rv)
		return filePath;
	else
		return nil;
}

- (void) reportError:(NSString *)err {
	NSLog(@"Asset manager error: %@", err);
	if ([delegate respondsToSelector:@selector(syncError:)])
		[delegate syncError:err];
}

- (void) doneDownloading:(NSString *)data:(NSString *)error {
	NSLog(@"Done!\n'%@'\n%@", data, error);
}

- (void) onProgress:(NSNumber *)recieved {
	if (totalTrackSize == 0)
		return;

	gotSoFar += [recieved intValue];
		
	progress = ((double)gotSoFar/(double)totalTrackSize)*0.75;

	if ([delegate respondsToSelector:@selector(progressUpdated:)])
		[delegate progressUpdated:progress];
}

- (id) jsonDataToObject:(NSString *)data {
	NSError *error = nil;
	SBJsonParser *parser = [SBJsonParser new];
	id obj = [parser objectWithString:data error:&error];
	if (error != nil)
		[self reportError:[NSString stringWithFormat:@"Error parsing JSON: %@", [error localizedDescription]]];
	[parser release];
	return obj;
}

- (void) loadSpots:(NSArray *)features {
	double progress_fraction = 0.25/(double)[features count];
	double total_progress = 0.75;
	for (NSDictionary *f in features) {
		NSDictionary *props = [f objectForKey:@"properties"];
		NSString *asset = [_assets objectForKey:[props objectForKey:@"sound"]];
		if (asset == nil)
			continue;
		SoundSpot *spot = [SpotFactory spotFromGeoJson:f asset:asset];
		if ([delegate respondsToSelector:@selector(soundSpotIsReady:)])
			[delegate soundSpotIsReady:spot];
		total_progress += progress_fraction;
		if ([delegate respondsToSelector:@selector(progressUpdated:)])
			[delegate progressUpdated:total_progress];
		
	}
}

- (void)completeSync:(NSTimer *)timer {
	if ([delegate respondsToSelector:@selector(completedSync)])
		[delegate completedSync];
	
	[timer invalidate];
}

- (void) doneGettingAreas:(NSString *)data:(NSString *)error {
	if (error != nil) {
		[self reportError:error];
		return;
	}

	NSDictionary *fc = [self jsonDataToObject:data];
	if (fc == nil)
		return;
	NSArray *features = [fc objectForKey:@"features"];

	[self loadSpots:features];

	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(completeSync:) userInfo:nil repeats:NO];

}

- (void) getAreas {
	NSString *u = [NSString stringWithFormat:@"%@/sound-areas?lon=%f&lat=%f",
				   defaultBaseUrl, _location.coordinate.longitude, _location.coordinate.latitude];
	
	[downloadHelper downloadData:[NSURL URLWithString:u] target:self done:@selector(doneGettingAreas::)
						progress:@selector(onProgress:)];
	
}

- (void) doneGettingTrack:(NSString *)data:(NSString *)error {
	if (error != nil) {
		[self reportError:error];
		return;
	}
	if (_current_track != nil) {
		[_assets setObject:_filePath forKey:_current_track];
		[_needed_tracks removeObjectForKey:_current_track];		
	}

	if ([_needed_tracks count] == 0) {
		if ([delegate respondsToSelector:@selector(progressUpdated:)])
			[delegate progressUpdated:0.75];

		[self getAreas];
		return;
	}
	
	NSArray *remaining = [_needed_tracks allKeys];
	_current_track = [remaining objectAtIndex:0];
	NSDictionary *fields = [_needed_tracks objectForKey:_current_track];

	NSURL *url = [NSURL URLWithString:[fields objectForKey:@"data"]];
	_filePath = [AssetManager AbsPath:[NSString stringWithFormat:@"%@.mp3", [fields objectForKey:@"sha1"]]];
	[downloadHelper downloadFile:url destination:_filePath target:self done:@selector(doneGettingTrack::) progress:@selector(onProgress:)];
	if ([delegate respondsToSelector:@selector(startedTrack::)])
		[delegate startedTrack:self.currentTrackNum:self.totalTrackNum];

}

- (void) doneGettingAbout:(NSString *)data:(NSString *)error {
	if (error != nil) {
		[self reportError:error];
		return;
	}
	[self doneGettingTrack:nil:nil];
}


- (void) doneGettingAssets:(NSString *)data:(NSString *)error {
	if (error != nil) {
		[self reportError:error];
		return;
	}
	NSArray *arr = [self jsonDataToObject:data];
	if (arr == nil)
		return;
	_needed_tracks = [[NSMutableDictionary dictionary] retain];
	_assets = [[NSMutableDictionary dictionary] retain];
	totalTrackSize = 0;
	for (NSDictionary *a in arr) {
		NSDictionary *fields = [a objectForKey:@"fields"];
		NSString *filePath = [self _trackDownloaded:[fields objectForKey:@"sha1"]];
		if (filePath != nil) {
			[_assets setObject:filePath forKey:[a objectForKey:@"pk"]];
		} else {
			[_needed_tracks setObject:fields forKey:[a objectForKey:@"pk"]];
			totalTrackSize += [[fields objectForKey:@"size"] integerValue]; 
			NSLog(@"Total track size: %d", totalTrackSize);
		}
	}
	NSLog(@"bing!");
	totalTrackNum = [_needed_tracks count];
	NSString *u = [NSString stringWithFormat:@"%@/about?lon=%f&lat=%f",
				   defaultBaseUrl, _location.coordinate.longitude, _location.coordinate.latitude];
	[downloadHelper downloadFile:[NSURL URLWithString:u] destination:[AssetManager AbsPath:@"about.html"]
						  target:self done:@selector(doneGettingAbout::) progress:@selector(onProgress:)];
}

- (void)startSync:(CLLocation *)location {
	downloadHelper = [[DownloadHelper alloc] init];
	NSString *u = [NSString stringWithFormat:@"%@/sound-assets?lon=%f&lat=%f",
				   defaultBaseUrl, location.coordinate.longitude, location.coordinate.latitude];

	totalTrackSize = 0;

	[downloadHelper downloadData:[NSURL URLWithString:u] target:self done:@selector(doneGettingAssets::) progress:@selector(onProgress:)];
	
	_location = [location retain];
	

}

- (long)currentTrackNum
{
	return totalTrackNum - [_needed_tracks count] + 1;
}

@end
