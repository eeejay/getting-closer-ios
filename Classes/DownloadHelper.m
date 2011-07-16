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

#import "DownloadHelper.h"

@implementation DownloadHelper

- (void) downloadInner:(NSURL *)url target:(id)targetObj done:(SEL)doneFunc progress:(SEL)progressFunc{
	NSLog(@"Starting download: %d %@", inSession, url.description);
#if 0 //WTF!
	if (inSession) {
		if (doneFunc != nil)
			[targetObj performSelector:doneFunc withObject:nil withObject:@"Download in progress"];
		return;
	}
#endif
	if (connection != nil)
		[connection dealloc];
	inSession = YES;
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
	target = [targetObj retain];
	done = doneFunc;
	progress = progressFunc;
}

- (void) downloadFile:(NSURL *)url destination:(NSString *)destination target:(id)targetObj done:(SEL)doneFunc progress:(SEL)progressFunc {
	[self downloadInner:url target:targetObj done:doneFunc progress:progressFunc];
	fileStream = [[NSOutputStream outputStreamToFileAtPath:destination append:NO] retain];
	filePath = [destination retain];
}

- (void) downloadData:(NSURL *)url target:(id)targetObj done:(SEL)doneFunc progress:(SEL)progressFunc {
	[self downloadInner:url target:targetObj done:doneFunc progress:progressFunc];
	downloadedData = [[NSMutableData data] retain];
}

- (void) resetConnection {
	NSLog(@"reset");
	[connection release];
	connection = nil;
	if (fileStream)
		[fileStream release];
	fileStream = nil;
	if (filePath)
		[filePath release];
	filePath = nil;
	if (downloadedData)
		[downloadedData release];
	downloadedData = nil;
	if (target)
		[target release];
	NSLog(@"set inSession to FALSE!");
	inSession = NO;
}

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
	NSLog(@"Got response %d", httpResponse.statusCode);
	if (httpResponse.statusCode != 200)
	{
		if (done != nil)
			[target performSelector:done withObject:nil
							withObject:[NSString stringWithFormat:@"Error syncing: got HTTP code %d", httpResponse.statusCode]];
		[connection cancel];
		[self resetConnection];
		return;
	}

	totalSize = [response expectedContentLength];
	sizeSoFar = 0;
	
	if (fileStream != nil)
		[fileStream open];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	NSInteger       dataLength = [data length];
    const uint8_t * dataBytes = [data bytes];
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar = 0;

	sizeSoFar += dataLength;
	
	if (progress != nil)
		[target performSelector:progress withObject:[NSNumber numberWithInt:dataLength]];

	if (downloadedData != nil) {
		[downloadedData appendData:data];
		return;
	}
	
    do {
        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %d", [error domain], [error code]);

	[connection cancel];

	if (done != nil)
		[target performSelector:done withObject:nil
					 withObject:[NSString stringWithFormat:@"Error syncing: %@", [error localizedDescription]]];

	[connection cancel];
	[self resetConnection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	NSLog(@"done");
	if (fileStream != nil)
		[fileStream close];
	
	NSString *result;
	
	if (filePath != nil)
		result = [filePath retain];
	
	if (downloadedData != nil)
		result = [[NSString alloc] initWithData:downloadedData encoding:4];

	[self resetConnection];

	if (done != nil)
		[target performSelector:done withObject:result withObject:nil];
	
	[result release];
}

@end
