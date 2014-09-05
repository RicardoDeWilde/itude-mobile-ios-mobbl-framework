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

#import "MBDefinition.h"
#import "MBOutcome.h"
#import "MBValueChangeListenerProtocol.h"
#import "MBTypes.h"

@class MBPage;
@class MBComponentContainer;
@class MBDocument;

@interface MBComponent : NSObject {
	
@private
	MBDefinition *_definition;
	MBComponentContainer *_parent;
	NSString *_style;
	NSDictionary *_viewData;
    BOOL _markedForDestruction;
	int _leftInset;
	int _rightInset;
	int _topInset;
	int _bottomInset;
}

@property (nonatomic, assign) MBDefinition *definition;
@property (nonatomic, assign) MBComponentContainer *parent;
@property (nonatomic, retain) NSString *style;
@property (nonatomic, assign) BOOL markedForDestruction;
@property (nonatomic, assign) int leftInset;
@property (nonatomic, assign) int rightInset;
@property (nonatomic, assign) int topInset;
@property (nonatomic, assign) int bottomInset;
@property (nonatomic, assign) MBDocument *document;

- (id) initWithDefinition:(id)definition document:(MBDocument*) document parent:(MBComponentContainer *) parent;
- (UIView*) buildViewWithMaxBounds:(CGRect) bounds forParent:(UIView*)parent viewState:(MBViewState) viewState;
- (void) handleOutcome:(MBOutcome *)outcome;
- (void) handleOutcome:(NSString *)outcomeName withPathArgument:(NSString*) path;
- (NSString*) substituteExpressions:(NSString*) expression;
- (NSString *) componentDataPath;
- (NSString *) absoluteDataPath;
- (NSString *) evaluatedDataPath;
- (MBDocument*) document;
- (MBPage*) page;
- (BOOL) resignFirstResponder;
- (BOOL) resignFirstResponder:(UIView*) view;
- (void) setupKeyboardHiding:(UIView*) view;
- (void) setViewData:(id) value forKey:(NSString*) key;
- (id) viewDataForKey:(NSString*) key;
- (NSString*) evaluateExpression:(NSString*) variableName;
- (NSString *) asXmlWithLevel:(int)level;
- (NSString*) attributeAsXml:(NSString*)name withValue:(id) attrValue;
- (NSString*) booleanAsXml:(NSString*)name withValue:(BOOL) attrValue;
- (void) translatePath;
- (void) registerViewController:(UIViewController*) controller;
- (NSMutableArray*) descendantsOfKind:(Class) clazz;
- (NSMutableArray*) descendantsOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value;
- (NSMutableArray*) childrenOfKind:(Class) clazz;
- (NSMutableArray*) childrenOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value;
- (id) firstDescendantOfKind:(Class) clazz; 
- (id) firstDescendantOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value;
- (id) firstChildOfKind:(Class) clazz;
- (id) firstChildOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value;
- (void) registerValueChangeListener:(id<MBValueChangeListenerProtocol>) listener forPath:(NSString*) path;
- (void) unregisterValueChangeListener:(id<MBValueChangeListenerProtocol>) listener;
- (void) unregisterValueChangeListener:(id<MBValueChangeListenerProtocol>) listener forPath:(NSString*) path;
- (BOOL) notifyValueWillChange:(NSString*) value originalValue:(NSString*) currentValue forPath:(NSString*) path;
- (void) notifyValueChanged:(NSString*) value originalValue:(NSString*) currentValue forPath:(NSString*) path;
- (NSString*) name;
- (NSString*) customAttributeForKey:(NSString*) key;
- (void) setCustomAttribute:(NSString*)value forKey: (NSString *) key;
@end
