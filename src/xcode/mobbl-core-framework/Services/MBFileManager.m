/*
 * (C) Copyright Itude Mobile B.V., The Netherlands.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//  MBFileLoader.m
//  mobbl-core-framework
//  Created by Robin Puthli on 07-02-2014.

#import "MBFileManager.h"
#import "MBMacros.h"

@implementation MBFileManager
- (NSData*) dataWithContentsOfMainBundle:(NSString*)name {
	
	NSString *fileName = [self getPathToExistingFile:name];
	DLog(@"Reading file: %@", fileName);
	NSData *data = nil;
    data = [NSData dataWithContentsOfFile:fileName];
    if (data == nil || [data length] ==0)
    {
        WLog(@"Unable to read file: %@", fileName);
    }
	return data;
}

- (NSString*) getPathToExistingFile:(NSString*) name {
	NSArray * const paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * const documentsDirectory = paths[0];
	
	NSString * const absoluteFilePath = [documentsDirectory stringByAppendingPathComponent: name];
	const BOOL fileExistsInDocumentDirectory = [[NSFileManager defaultManager] fileExistsAtPath:absoluteFilePath];
    
	if (fileExistsInDocumentDirectory) {
        return absoluteFilePath;
    } else {
		// check for .xml file in bundle
        NSBundle * const appBundle = [NSBundle bundleForClass:[self class]];
		NSString * const absoluteFilePathInBundle = [[appBundle bundlePath] stringByAppendingPathComponent: name];
		const BOOL fileExistsInBundle = [[NSFileManager defaultManager] fileExistsAtPath:absoluteFilePathInBundle];
        
		if (fileExistsInBundle) {
			return absoluteFilePathInBundle;
		}
	}
    
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: name];
}

-(NSString*) determineFileName:(NSString*) name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = paths[0];
    
	NSString *absoluteFilePath = [documentsDirectory stringByAppendingPathComponent: name];
    
    return absoluteFilePath;
}

-(void) writeContents:(NSString*) contentString toFileName:(NSString*) fileName{
    NSString *absPath = [self determineFileName:fileName];
    NSError *error;
    DLog(@"Writing document %@ to %@",  fileName, absPath);
    BOOL success = [contentString writeToFile:absPath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
    if(!success) WLog(@"Error writing document %@ to %@: %i %@", fileName, absPath, [error code], [error domain]);

}

@end
