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

@class DownloadHelper;

@interface DownloadHelper : NSObject {
	
	NSURLConnection *connection;
	NSOutputStream *fileStream;
	NSString *filePath;
	SEL done;
	SEL progress;
	NSInteger totalSize;
	NSInteger sizeSoFar;
	NSMutableData *downloadedData;
	BOOL inSession;
	id target;
}

- (void) downloadFile:(NSURL *)url destination:(NSString *)destination target:(id)targetObj done:(SEL)doneFunc progress:(SEL)progressFunc;
- (void) downloadData:(NSURL *)url target:(id)targetObj done:(SEL)doneFunc progress:(SEL)progressFunc;



@end
