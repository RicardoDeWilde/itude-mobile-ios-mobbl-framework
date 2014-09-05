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
#import "MBFileDataHandler.h"
#import "MBDocumentFactory.h"
#import "MBMetadataService.h"
#import "MBResourceService.h"

@implementation MBFileDataHandler

- (MBDocument *) loadDocument:(NSString *)documentName {
	DLog(@"Load %@", documentName);
	MBDocumentDefinition *docDef = [[MBMetadataService sharedInstance] definitionForDocumentName: documentName];
    NSString *xmlFileName = [documentName stringByAppendingString:@".xml"];
	NSData *data = [[MBResourceService sharedInstance].fileManager dataWithContentsOfMainBundle: xmlFileName];
	if(data == nil || [data length] < 1) return nil;
	else return [[MBDocumentFactory sharedInstance] documentWithData: data withType: PARSER_XML andDefinition:docDef];
}

- (MBDocument *) loadDocument:(NSString *)documentName withArguments:(MBDocument *)args {
    // File does not know what to do with arguments; so just ignore them
    return [self loadDocument: documentName];
}

- (void) storeDocument:(MBDocument *)document {
    
	if(document != nil) {
		NSString *xml = [document asXmlWithLevel:0];
        NSString *xmlFileName = [[document name] stringByAppendingString:@".xml"];
        [[MBResourceService sharedInstance].fileManager writeContents: xml toFileName:xmlFileName];
	}
    else{
        WLog(@"Null Document!! Cannot store");
        
    }
}




@end
