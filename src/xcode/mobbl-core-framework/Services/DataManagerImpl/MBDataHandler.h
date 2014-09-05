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

#import "MBDocument.h"
#import "MBDataHandler.h"


@class MBDocumentOperation;


/** Protocol for loading and storing MBDocument instances.
 */
@protocol MBDataHandler

/// @name Loading a document
/** Loads a document. May return a cached value.
@param documentName the name of the document as defined in `documents.xmlx`
*/
- (MBDocument *) loadDocument:(NSString *)documentName;

/**
 Loads a document, ignoring any cached values.
*/
- (MBDocument *) loadFreshDocument:(NSString *)documentName;

/** Loads a document with arguments. May return a cached value.
 @param documentName the name of the document as defined in `documents.xmlx`
 @param args MBDocument containing arguments.
 */
- (MBDocument *) loadDocument:(NSString *)documentName withArguments:(MBDocument*) args;

/** Loads a document with arguments, ignoring any cached values. */
- (MBDocument *) loadFreshDocument:(NSString *)documentName withArguments:(MBDocument*) args;

/// @name Storing a document
/** Stores the given document. */
- (void) storeDocument:(MBDocument *)document;


- (MBDocumentOperation*) createDocumentLoadOperation:(id<MBDataHandler>) dataHandler documentName:(NSString*) documentName arguments:(MBDocument*) arguments;

- (MBDocumentOperation*) createDocumentStoreOperation:(id<MBDataHandler>) dataHandler document:(MBDocument*) document;


@end
