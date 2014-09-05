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

#import "MBElement.h"
#import "MBAttributeDefinition.h"
#import "MBDocumentDefinition.h"
#import "StringUtilities.h"

@interface MBElement()
  -(void) setDefinition:(MBElementDefinition*) definition;
  -(NSString*) attributeAsXml:(NSString*)name withValue:(id) attrValue;
  -(NSString*) cookValue:(NSString*) uncooked;
@end

@interface MBElementContainer()
- (void) copyChildrenInto:(MBElementContainer*) other;
- (void) addAllPathsTo:(NSMutableSet*) set currentPath:(NSString*) currentPath;
@end

@implementation MBElement

-(id) initWithDefinition:(id) definition {
	self = [super init];
	if (self != nil) {
		self.definition = definition;
		_values = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[_definition release];
	[_values release];
	[super dealloc];
}

- (id) copy {
	MBElement *newElement = [[MBElement alloc] initWithDefinition: self.definition];
	[newElement->_values addEntriesFromDictionary:_values];
	[self copyChildrenInto: newElement];
	return newElement;
}

- (void) assignByName:(MBElementContainer*) other {
	[other deleteAllChildElements];

	MBElementDefinition *def = self.definition;
	for(MBAttributeDefinition *attrDef in [def attributes]) {
		if([other.definition isValidAttribute: attrDef.name]) {
			[other setValue:[self valueForAttribute: attrDef.name] forKey:attrDef.name];
		}
	}
	
	for(NSString *elementName in [_elements allKeys]) {
		for(MBElement *src in [_elements valueForKey:elementName]) {
			MBElement *newElem = [other createElementWithName: src.definition.name];
			[src assignByName:newElem];
		}
	}
}

- (void) assignToElement:(MBElement*) target {
	if(![target->_definition.name isEqualToString:_definition.name]) {
		NSString *msg = [NSString stringWithFormat:@"Cannot assign element since types differ: %@ != %@ (use assignByName:)", target->_definition.name, _definition.name];
		@throw [NSException exceptionWithName:@"CannotAssign" reason:msg userInfo:nil];
		
	}
	[target->_values removeAllObjects];
	[target->_values addEntriesFromDictionary:_values];
	[target->_elements removeAllObjects];
	[self copyChildrenInto: target];
}

- (NSString*) uniqueId {
	NSMutableString *uid = [NSMutableString stringWithCapacity:200];
	[uid appendFormat:@"%@", [self definition].name];
	for(MBAttributeDefinition* def in [_definition attributes]) {
		NSString *attrName = def.name;
		if(![attrName isEqualToString:@"xmlns"]) {
			NSString *attrValue = [_values valueForKey: attrName];
			[uid appendString: @"_"];
			if(attrValue != nil) [uid appendString: [self cookValue: attrValue]];
		}
	}
	[uid appendString:[super uniqueId]];
	return uid;
}

-(void) addAllPathsTo:(NSMutableSet*) set currentPath:(NSString*) currentPath {
	
	NSString *elementName = [[self definition]name];
#pragma unused(elementName)
	
	for(NSString *attr in [_values allKeys]) {
		[set addObject: [NSString stringWithFormat:@"%@/@%@", currentPath, attr]]; 	
	}
	[super addAllPathsTo:set currentPath:currentPath];
}


- (id) valueForPathComponents:(NSMutableArray*)pathComponents withPath: (NSString*) originalPath nillIfMissing:(BOOL) nillIfMissing translatedPathComponents:(NSMutableArray*)translatedPathComponents {
    if([pathComponents count] > 0 && [[pathComponents objectAtIndex:0] hasPrefix:@"@"]) {
	   NSString *attrName = [pathComponents objectAtIndex:0];
		[translatedPathComponents addObject:attrName];
	   return [self valueForAttribute: [attrName substringFromIndex:1]];
	}
	else return [super valueForPathComponents: pathComponents withPath:originalPath nillIfMissing: nillIfMissing translatedPathComponents:translatedPathComponents];
}

-(BOOL) isValidAttribute:(NSString*) attributeName {
	return [[self definition] isValidAttribute: attributeName];
}

-(void) validateAttribute:(NSString*) attributeName {
	if(![self isValidAttribute: attributeName]) {
     	NSString *msg = [NSString stringWithFormat:@"Attribute %@ not defined for element %@. Use one of %@", attributeName, [[self definition] name], [[self definition] attributeNames]];
     	@throw [NSException exceptionWithName: @"InvalidAttributeName" reason:msg userInfo:nil];
	}
}

-(void) setValue:(NSString *)value forPath:(NSString *)path {
	if([path hasPrefix:@"@"]) [self setValue:value forAttribute:[path substringFromIndex:1]];
	else [super setValue:value forPath:path];
}

-(void) setValue:(id)value forAttribute:(NSString *)attributeName {
	[self setValue:value forAttribute:attributeName throwIfInvalid: TRUE];	
}

- (void) setValue:(id)value forAttribute:(NSString *)attributeName throwIfInvalid:(BOOL) throwIfInvalid {
	if(throwIfInvalid) {
		[self validateAttribute: attributeName];
		[_values setValue:value forKey:attributeName];
	}
	else {
		if([self isValidAttribute: attributeName]) [_values setValue:value forKey:attributeName];
	}
}

-(NSString*) valueForAttribute:(NSString*)attributeName {
	[self validateAttribute: attributeName];
	return [_values valueForKey:attributeName];
}

-(id) valueForKey:(NSString *)key {
	return [self valueForAttribute:key];	
}

-(void) setValue:(id)value forKey:(NSString *)key {
	[self setValue:value forAttribute:key];	
}

-(void) setDefinition:(MBElementDefinition*) definition {
	[definition retain];
	_definition = definition;
}

- (id) definition {
	return _definition;
}

-(NSString*) cookValue:(NSString*) uncooked {
	if(uncooked == nil) return nil;
	
	NSMutableString *cooked = [NSMutableString stringWithString:@""];
	for(int i=0; i<[uncooked length]; i++) {
		int c = [uncooked characterAtIndex:i];
		if(c < 32 || c=='&' || c=='\'' || c>126) [cooked appendFormat:@"&#%i;", c];
		else [cooked appendFormat:@"%c", c];
	}
	return cooked;
}

-(NSString*) attributeAsXml:(NSString*)name withValue:(id) attrValue {
	
	NSString *escaped = [attrValue xmlSimpleEscape];
	return attrValue == nil?@"": [NSString stringWithFormat:@" %@='%@'", name, escaped];
}

- (NSString *) bodyText {
	if([self isValidAttribute: TEXT_ATTRIBUTE]) return [self valueForAttribute:TEXT_ATTRIBUTE];	
	return nil;
}

-(void) setBodyText:(NSString*) text {
	[self setValue:text forAttribute:TEXT_ATTRIBUTE];	
}

- (NSString *) asXmlWithLevel:(int)level
{
	BOOL hasBodyText = [self isValidAttribute: TEXT_ATTRIBUTE] && [[self bodyText] length] > 0;
	NSMutableString *result = [NSMutableString stringWithFormat: @"%*s<%@", level, "", _definition.name];
	for(MBAttributeDefinition* def in [_definition attributes]) {
		NSString *attrName = def.name;
		NSString *attrValue = [_values valueForKey: attrName];
		if(![attrName isEqualToString:TEXT_ATTRIBUTE]) [result appendString: [self attributeAsXml:attrName withValue:attrValue]];
	}
	if([[_definition children] count] == 0 && !hasBodyText)
		[result appendString:@"/>\n"];
	else {
		[result appendString:@">"];
		if(hasBodyText) 
			[result appendString: [[self bodyText] xmlSimpleEscape]];
		else [result appendString: @"\n"];

		for(MBElementDefinition *elemDef in [_definition children]) {
			NSArray *lst = [[self elements] objectForKey:elemDef.name];
			for(MBElement *elem in lst)
					[result appendString: [elem asXmlWithLevel: level+2]];
			}
		
		[result appendFormat:@"%*s</%@>\n", hasBodyText?0:level, "", _definition.name];
	}

	return result;
}

- (NSString *) description {
	return [self asXmlWithLevel: 0];
}

- (NSString *) name {
	return [self definition].name;
}

- (NSInteger) physicalIndexWithCurrentPath: (NSString *)path {
	NSMutableArray *pathComponents = [path splitPath];
	NSString *lastPathComponent = [pathComponents objectAtIndex:[pathComponents count] - 1];
	NSArray *elementComponentParts = [lastPathComponent componentsSeparatedByString:@"["];
	NSString *elementName = [elementComponentParts objectAtIndex:0];
	
	if([elementName isEqualToString: [self name]]) {
		NSMutableString *idxStr = [NSMutableString stringWithString: [elementComponentParts objectAtIndex:1]];
		[idxStr replaceOccurrencesOfString:@"]" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [idxStr length])];
		return [idxStr intValue];
	}else {
		NSString *msg = [NSString stringWithFormat:@"Path %@ not for element %@.", path, [self name]];
     	@throw [NSException exceptionWithName: @"InvalidElementPath" reason:msg userInfo:nil];
	}
    
	return -1;
}

@end
