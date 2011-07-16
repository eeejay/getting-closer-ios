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

#import "Checksum.h"


@implementation Checksum

+ (NSString *)getSha1:(NSString *)filePath {
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    
    CC_SHA1_CTX sha1;
    
    CC_SHA1_Init(&sha1);
        
    NSData* fileData;
	
    do {
		fileData = [handle readDataOfLength:1024];
        CC_SHA1_Update(&sha1, [fileData bytes], [fileData length]);
    } while ([fileData length] == 1024);
	
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &sha1);
	
    NSString* checksum = [NSString stringWithFormat:
						  @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
						  digest[0], digest[1], 
						  digest[2], digest[3],
						  digest[4], digest[5],
						  digest[6], digest[7],
						  digest[8], digest[9],
						  digest[10], digest[11],
						  digest[12], digest[13],
						  digest[14], digest[15],
						  digest[16], digest[17],
						  digest[18], digest[19]];
	
    return checksum;
}

@end