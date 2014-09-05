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
#import "MBMetadataService.h"
#import "MBMvcConfigurationParser.h"
#import "DataUtilites.h"
#import "MBResourceService.h"


#define C_CONFIGURATION_CONFIG_NAME @"config.xml"
#define C_CONFIGURATION_ENDPOINTS_NAME @"endpoints.xml"


static MBMetadataService *_instance = nil;

@interface MBMetadataService () {
	MBConfigurationDefinition* _configuration;
    NSString *_configName;
    NSString *_endpointsName;
}

@end

@implementation MBMetadataService

@synthesize configName = _configName;
@synthesize endpointsName = _endpointsName;
@synthesize configuration = _configuration;

-(void) dealloc {
    [_configName release];
    [_endpointsName release];
	[_configName release];
	[super dealloc];
}

-(id) init {
	self = [super init];
	if(self != nil) {
        [self setConfigName:C_CONFIGURATION_CONFIG_NAME];
        [self setEndpointsName:C_CONFIGURATION_ENDPOINTS_NAME];
	}
	return self;
}


#pragma mark -
#pragma mark Instance

+(MBMetadataService *) sharedInstance {
	@synchronized(self) {
		if(_instance == nil) {
			_instance = [[self alloc] init];
		}
	}
	return _instance;
}


#pragma mark -
#pragma mark Configuratoin

-(MBDocumentDefinition *) definitionForDocumentName:(NSString *)documentName {
	return [self definitionForDocumentName:documentName throwIfInvalid: TRUE];
}

-(MBDocumentDefinition *) definitionForDocumentName:(NSString *)documentName throwIfInvalid:(BOOL) doThrow {
	MBDocumentDefinition *docDef = [self.configuration definitionForDocumentName: documentName];
	if(docDef == nil && doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Document with name %@ not defined", documentName];
		@throw [[[NSException alloc]initWithName:@"DocumentNotDefined" reason:msg userInfo:nil]autorelease];
	}
	return docDef;
}

-(MBDomainDefinition *) definitionForDomainName:(NSString *)domainName {
	return [self definitionForDomainName: domainName throwIfInvalid: TRUE];
}

-(MBDomainDefinition *) definitionForDomainName:(NSString *)domainName throwIfInvalid:(BOOL) doThrow {
	MBDomainDefinition *domDef = [self.configuration definitionForDomainName: domainName];
	if(domDef == nil && doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Domain with name %@ not defined", domainName];
		@throw [[[NSException alloc]initWithName:@"DomainNotDefined" reason:msg userInfo:nil] autorelease];
	}
	return domDef;
}

-(MBPageDefinition *) definitionForPageName:(NSString *)pageName {
    return [self definitionForPageName: pageName throwIfInvalid: TRUE];
}

-(MBPageDefinition *) definitionForPageName:(NSString *)pageName throwIfInvalid:(BOOL) doThrow {
	MBPageDefinition *pageDef = [self.configuration definitionForPageName: pageName];
	if(pageDef == nil && doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Page with name %@ not defined", pageName];
		@throw [[[NSException alloc]initWithName:@"PageNotDefined" reason:msg userInfo:nil] autorelease];
	}
	return pageDef;
}

-(MBActionDefinition *) definitionForActionName:(NSString *)actionName {
	return [self definitionForActionName: actionName throwIfInvalid: TRUE];
}

-(MBActionDefinition *) definitionForActionName:(NSString *)actionName throwIfInvalid:(BOOL) doThrow {
	MBActionDefinition *actionDef = [self.configuration definitionForActionName: actionName];
	if(actionDef == nil && doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Action with name %@ not defined", actionName];
		@throw [[[NSException alloc]initWithName:@"ActionNotDefined" reason:msg userInfo:nil] autorelease];
	}
	return actionDef;
}

#pragma mark -
#pragma mark Dialog Definitions

- (NSArray *)dialogDefinitions {
    return [[self.configuration dialogs] allValues];
}

-(MBDialogDefinition *)definitionForDialogName:(NSString *)dialogName {
	return [self definitionForDialogName:dialogName throwIfInvalid:TRUE];
}

-(MBDialogDefinition *) definitionForDialogName:(NSString *)dialogName throwIfInvalid:(BOOL) doThrow {
	MBDialogDefinition *dialogDefinition = [self.configuration definitionForDialogName:dialogName];
	if(dialogDefinition == nil && doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Dialog with name %@ not defined", dialogName];
		@throw [[[NSException alloc]initWithName:@"DialogNotDefined" reason:msg userInfo:nil] autorelease];
	}
	return dialogDefinition;
}

-(MBDialogDefinition *) dialogDefinitionForPageStackName:(NSString *)pageStackName {
	return [self dialogDefinitionForPageStackName:pageStackName throwIfInvalid:TRUE];
}

-(MBDialogDefinition *) dialogDefinitionForPageStackName:(NSString *)pageStackName throwIfInvalid:(BOOL) doThrow {
    for (MBDialogDefinition *dialogDef in [self.configuration.dialogs allValues]) {
        for (MBPageStackDefinition *stackDef in dialogDef.pageStacks) {
            if ([pageStackName isEqualToString:stackDef.name]) {
                return dialogDef;
            }
        }
        
        // in case we have an implicit stack
        if (dialogDef.pageStacks.count == 0 && [dialogDef.name isEqualToString:pageStackName]) {
            return dialogDef;
        }
    }
    
	if(doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Dialog for stack %@ not defined", pageStackName];
		@throw [[[NSException alloc]initWithName:@"DialogNotDefined" reason:msg userInfo:nil] autorelease];
	}
	return nil;
}

#pragma mark -
#pragma mark Alert Definitions


- (MBAlertDefinition *)definitionForAlertName:(NSString *)alertName {
    return [self definitionForAlertName:alertName throwIfInvalid:TRUE];
}

- (MBAlertDefinition *)definitionForAlertName:(NSString *)alertName throwIfInvalid:(BOOL)doThrow {
    MBAlertDefinition *alertDef = [self.configuration definitionForAlertName:alertName];
    if (alertDef == nil && doThrow) {
        NSString *msg = [NSString stringWithFormat: @"Alert with name %@ not defined", alertName];
		@throw [[[NSException alloc]initWithName:@"AlertNotDefined" reason:msg userInfo:nil] autorelease];
    }
	return alertDef;
}

// For now do not raise an exception if an outcome is not defined
-(NSArray *) outcomeDefinitionsForOrigin:(NSString *)originName {
	
	NSArray *lst = [self.configuration outcomeDefinitionsForOrigin: originName];
	if(lst == nil || [lst count] == 0) WLog(@"WARNING No outcomes defined for origin %@ ", originName);
    
	return lst;
}

-(NSArray*) outcomeDefinitionsForOrigin:(NSString*) originName outcomeName:(NSString*) outcomeName {
	return [self outcomeDefinitionsForOrigin:originName outcomeName: outcomeName throwIfInvalid: TRUE];
}

-(NSArray*) outcomeDefinitionsForOrigin:(NSString*) originName outcomeName:(NSString*) outcomeName throwIfInvalid:(BOOL) doThrow {
	NSArray *ocDefs = [self.configuration outcomeDefinitionsForOrigin:originName outcomeName:outcomeName];
	if([ocDefs count] == 0 && doThrow) {
		NSString *msg = [NSString stringWithFormat: @"Outcome with originName=%@ outcomeName=%@ not defined", originName, outcomeName];
		@throw [[[NSException alloc]initWithName:@"ActionNotDefined" reason:msg userInfo:nil] autorelease];
	}
	return ocDefs;
}


#pragma mark -
#pragma mark Getters and Setters

- (void)setConfigName:(NSString *)configName {
    if (_configName != configName) {
        @synchronized(self) {
            [_configName release];
            _configName = [configName retain];
            
            // We need to reload the configuration
            [_configuration release];
            _configuration = nil;
        }
    }
}

- (MBConfigurationDefinition *)configuration {
    if (!_configuration) {
        MBMvcConfigurationParser *parser = [MBMvcConfigurationParser new];
        NSData *data = [[MBResourceService sharedInstance].fileManager dataWithContentsOfMainBundle:self.configName];
        _configuration = [[parser parseData:data ofDocument:self.configName] retain];
        [parser release];
    }
    return _configuration;
}

@end



#pragma mark -
#pragma mark Deprecated methods

/**
 * WARNING! The methods below are DEPRECATED! PLEASE USE THE SUGGESTED METHOD IN THE COMMENTS. THESE METHODS WILL BE REMOVED OVER TIME
 */
@implementation MBMetadataService (Deprecated)

/** DEPRECATED!!! */
+(void) setConfigName:(NSString*) name {
    [[MBMetadataService sharedInstance] setConfigName:name];
}

/** DEPRECATED!!! */
+(void) setEndpointsName:(NSString*) name {
    [[MBMetadataService sharedInstance] setEndpointsName:name];
}

/** DEPRECATED!!!  */
+(NSString *) getEndpointsName{
	return [[MBMetadataService sharedInstance] endpointsName];
}

@end
