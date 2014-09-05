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

#import "MBMacros.h"
#import "MBDataHandlerBase.h"
#import "MBMetadataService.h"
#import "MBDocumentOperation.h"

@implementation MBDataHandlerBase

- (MBDocument *) loadDocument:(NSString *)documentName {
	WLog(@"No loadDocument implementation for %@", documentName);
	return nil;
}

- (MBDocument *) loadFreshDocument:(NSString *)documentName {
	WLog(@"No loadFreshDocument implementation for %@", documentName);
	return nil;
}

- (MBDocument *) loadDocument:(NSString *)documentName withArguments:(MBDocument*) args {
	WLog(@"No loadDocument:withArguments implementation for %@", documentName);
	return nil;	
}

- (MBDocument *) loadFreshDocument:(NSString *)documentName withArguments:(MBDocument*) args {
	WLog(@"No loadFreshDocument:withArguments implementation for %@", documentName);
	return nil;	
}

- (void) storeDocument:(MBDocument *)document {
	WLog(@"No storeDocument implementation for %@", [[document definition]name]);	
}

- (MBDocumentOperation*) createDocumentLoadOperation:(id<MBDataHandler>) dataHandler documentName:(NSString*) documentName arguments:(MBDocument*) arguments {
	return [[[MBDocumentOperation alloc] initWithDataHandler:dataHandler documentName:documentName arguments:arguments] autorelease];

}

- (MBDocumentOperation*) createDocumentStoreOperation:(id<MBDataHandler>) dataHandler document:(MBDocument*) document {
	return [[[MBDocumentOperation alloc] initWithDataHandler:dataHandler document:document] autorelease];

}


@end
