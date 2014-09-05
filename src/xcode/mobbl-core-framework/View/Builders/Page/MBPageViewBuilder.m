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

#import "MBPageViewBuilder.h"
#import "MBPage.h"
#import "MBStyleHandler.h"
#import "MBViewManager.h"
#import "MBTypes.h"

@implementation MBPageViewBuilder

-(UIView*) buildPageView:(MBPage*) page withMaxBounds:(CGRect) maxBounds viewState:(MBViewState) viewState {
	UIView *view = [[[UIView alloc] initWithFrame: maxBounds] autorelease];  

    [self rebuildPageView:page currentView:view withMaxBounds:maxBounds viewState:viewState];
    
	return view;	
}

-(void)rebuildPageView:(MBPage *)page currentView:(UIView *)view withMaxBounds:(CGRect)maxBounds viewState:(MBViewState)viewState {
    // create a copy to make sure iterator doesn't break
    for (UIView *child in [view.subviews.copy autorelease])
        child.removeFromSuperview;
    
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	[page setupKeyboardHiding: view];
	
	[self buildChildren: [page children]
				forView: view
	   horizontalLayout: FALSE
				 bounds: maxBounds
			  viewState: viewState];
    
	[[self styleHandler] applyStyle:page forView:view viewState: viewState];

    
}

@end
