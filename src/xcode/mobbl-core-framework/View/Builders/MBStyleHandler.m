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

#import "MBStyleHandler.h"
#import "MBField.h"
#import "MBPage.h"
#import "MBPanel.h"
#import "MBForEachItem.h"
#import "MBForEach.h"
#import "MBComponent.h"
#import "MBFieldTypes.h"
#import "LocaleUtilities.h"
#import "MBLocalizationService.h"
#import "MBDevice.h"
#import "StringUtilities.h"

@interface MBStyleHandler(hidden)
- (void) alignLabel:(UILabel *)label forAlignMent:(NSString *)alignment;
@end

@implementation MBStyleHandler

-(void) applyStyle:(id) component forView:(UIView*) view viewState:(MBViewState) viewState {
    
	if([component isKindOfClass:[MBField class]]) {
		[self applyStyle: view field: component viewState: viewState];
	}
	else if([component isKindOfClass:[MBPage class]]) {
		[self applyStyle: view page: component viewState: viewState];
	}
	else if([component isKindOfClass:[MBPanel class]]) {
		[self applyStyle:view panel: component viewState: viewState];
	}
	else if([component isKindOfClass:[MBForEachItem class]]) {
		
	}
	else if([component isKindOfClass:[MBForEach class]]) {
		
	}
}

-(void) applyStyle:(UIView *)contentView page:(MBPage *)page viewState:(MBViewState)viewState {
    
}

- (void) applyStyle:(UIView *)view panel:(MBPanel *)panel viewState:(MBViewState) viewState {
	if([panel.type isEqualToString:@"MATRIX"] || [panel.type isEqualToString:@"LIST"]) {
		UITableView *tableView = (UITableView*)view;
		[self styleTableView:tableView panel:panel viewState:viewState];
	}
}

- (void) applyStyle:(UIView*) view field:(MBField*) field viewState:(MBViewState) viewState {
    
	if([field.type isEqualToString: C_FIELD_LABEL]) [self styleLabel: view component: field];
    else if([field.type isEqualToString: C_FIELD_SUBLABEL]) [self styleSubLabel: view component: field];
	else if([field.type isEqualToString: C_FIELD_BUTTON]) [self styleButton: view component: field];
	
}

- (void) styleLabel:(UIView*) view component:(MBField*) field {
	if([view isKindOfClass:[UILabel class]]) {
		UILabel *label = (UILabel*) view;
		label.backgroundColor = [UIColor clearColor];
        
		/*
         CGFloat size =[UIFont labelFontSize];
         label.font = [label.font fontWithSize:size];
         */
		[self alignLabel:label forAlignMent:field.alignment];
	}
}

- (void) styleSubLabel:(UIView*) view component:(MBField*) field {
	if([view isKindOfClass:[UILabel class]]) {
		UILabel *label = (UILabel*) view;
		label.backgroundColor = [UIColor clearColor];
		/*
         CGFloat size =[UIFont smallSystemFontSize];
         label.font = [label.font fontWithSize:size];
         */
		[self alignLabel:label forAlignMent:field.alignment];
	}
}


- (void) styleMultilineLabel:(UIView*) view component:(MBField*) field {
	[self styleLabel:view component:field];
}

- (void) styleWebView:(UIView*) view component:(MBField*) field {
	if([view isKindOfClass:[UIWebView class]]) {
		UIWebView *webView = (UIWebView*) view;
		webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO; // The webview does not know backgroundColor so if you set clearColor as backgroundColor, set opague to FALSE.
	}
}

- (CGFloat) heightForField:(MBField *) field forTableView:(UITableView *)tableView {
    
    CGFloat height = 44; // 44 is default tableview height
    if ([C_FIELD_TEXT isEqualToString:field.type]) {
        NSString *text = [field formattedValue];
        if (![text hasHTML]) {
            // calculate bounding box
            CGSize constraint = CGSizeMake(tableView.frame.size.width - 20, 50000); // TODO -- shouldn't hard code the -20 for the label size here
            
            // iOS 7
            if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                CGRect textViewSize = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:[NSDictionary dictionaryWithObjectsAndKeys:[self fontForField:field],NSFontAttributeName, nil] context:nil];
                height = textViewSize.size.height + 22;
            }
            // iOS6 and earlier
            else {
                CGSize size = [text sizeWithFont:[self fontForField:field] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                height = size.height + 22; // inset
            }
            
        }
    }
    
    return height;
}

- (UIFont *) fontForField:(MBField *) field {
	UIFont *font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	return font;
}

- (UIColor *)textColorForField:(MBField *)field {
    return [UIColor blackColor];
}

- (UIColor *)backgroundColorField:(MBField *)field {
    return [UIColor whiteColor];
}

- (void) styleTextfield:(UIView*) view component:(MBField*) field {
	if([view isKindOfClass:[UITextField class]]) {
        
		UITextField *textField = (UITextField*) view;
		textField.textAlignment = NSTextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.backgroundColor = [UIColor clearColor];
		textField.borderStyle = UITextBorderStyleRoundedRect;
	}
}

// Override this method to create a styled button. If this method is not overridden, the framework will create a round-rect Button
- (UIButton *)createStyledButton:(MBField *)field {
	return nil;
}

- (void) styleButton:(UIView *) view component:(MBField *)field {
	if ([view isKindOfClass:[UIButton class]]) {
		
		// We need some default style. otherwise the button will NOT be visible
		// TODO: Create some default style
		UIButton *button = (UIButton *) view;
		[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[button setBackgroundColor:[UIColor lightGrayColor]];
        
	}
}

// Applies style to the UITableView
- (void) styleTableView:(UITableView *)tableView panel:(MBPanel *)panel viewState:(MBViewState)viewState{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

// Apply style to a title in a matrix-header
- (void) styleMatrixHeaderTitle:(UIView *)view {
	if ([view isKindOfClass:[UILabel class]]) {
		
		// Set a default font
		// TODO: Maybe we want to change this. We can't let it be the default values that the Iphone decides,
		// because everything will be way to big to fit in the matrixCells
		UIFont *defaultFont = [UIFont fontWithName:@"Helvetica" size:16];
		
		UILabel *label = (UILabel *)view;
		label.backgroundColor = [UIColor clearColor];
		label.font = defaultFont;
		
	}
}

// Apply style to a cell in a matrix-header
- (void) styleMatrixHeaderCell:(UIView *)view  component:(MBMatrixCell *)cell  {
	if ([view isKindOfClass:[UILabel class]]) {
		
		// Set a default font
		// TODO: Maybe we want to change this. We can't let it be the default values that the Iphone decides,
		// because everything will be way to big to fit in the matrixCells
		UIFont *defaultFont = [UIFont fontWithName:@"Helvetica" size:11];
		
		UILabel *label = (UILabel *)view;
		label.backgroundColor = [UIColor clearColor];
		label.font = defaultFont;
		
		[self alignLabel:label forAlignMent:cell.alignment];
		
	}
}

// Apply style to a title in a matrix-row
- (void) styleMatrixRowTitle:(UIView *)view {
	if ([view isKindOfClass:[UILabel class]]) {
		
		// Set a default font
		// TODO: Maybe we want to change this. We can't let it be the default values that the Iphone decides,
		// because everything will be way to big to fit in the matrixCells
		UIFont *defaultFont = [UIFont fontWithName:@"Helvetica" size:16];
		
		UILabel *label = (UILabel *)view;
		label.backgroundColor = [UIColor clearColor];
		label.font = defaultFont;
        
	}
}

// Apply style to a cell in a matrix-row
- (void) styleMatrixRowCell:(UIView *)view component:(MBMatrixCell *)cell {
	if ([view isKindOfClass:[UILabel class]]) {
		
		// Set a default so the layout is correct.
		// TODO: Maybe we want to change this. We can't let it be the default for Iphone, because everything will be way to big to fit in the matrixCells
		UIFont *defaultFont = [UIFont fontWithName:@"Helvetica" size:11];
		
		UILabel *label = (UILabel *)view;
		label.backgroundColor = [UIColor clearColor];
		label.font = defaultFont;
		
		// Align the label
		[self alignLabel:label forAlignMent:cell.alignment];
		
	}
}

- (void) styleNavigationBar:(UINavigationBar*) bar {
	// Override in overridden styleHandler
}

- (void) styleTabBarController:(UITabBarController *) tabBarController {
	// Override in overridden styleHandler
}


-(void) styleToolbar:(UIToolbar *)toolbar {
	// Override in overridden styleHandler
}

- (void) styleDatePicker:(UIDatePicker *)datePicker component:(MBField *)field {
    // Override in overridden styleHandler
}

- (void) styleSwitch:(UISwitch *)switchView component:(MBField *)field {
    // Override in superclass
}

- (CGSize) sizeForSplitViewController:(MBSplitViewController *) splitViewcontroller {
	// Override in overridden styleHandler
	return splitViewcontroller.view.frame.size;
}

- (CGRect) sizeForTextField:(MBField*) field withMaxBounds:(CGRect) bounds  {
	
	// Possibly handle CGRectZero for bounds
	// TODO: possibly make a difference here for the field.type = LABEL | TEXTFIELD
    // The Label of a inputField is in a container that has half the width
    if ([field.type isEqualToString:C_FIELD_INPUT] ||
        [field.type isEqualToString:C_FIELD_PASSWORD]) {
        CGFloat margin = 10.0;
        CGFloat width = (bounds.size.width/2);
        CGFloat height = 25;
        return CGRectMake(width, (bounds.size.height/2)-(height/2), width-margin, height);
    }
    
    return CGRectMake(150.0, 0.0, 140.0, 25.0);
}

- (CGRect) sizeForLabel:(MBField*) field withMaxBounds:(CGRect) bounds {
    
    // The Label of a inputField is in a container that has half the width
    if ([field.type isEqualToString:C_FIELD_INPUT] ||
        [field.type isEqualToString:C_FIELD_CHECKBOX]) {
        CGFloat margin = ([MBDevice iOSVersion] < 7.0f) ? 10.0 : 15.0;
        CGFloat width = [field.type isEqualToString:C_FIELD_CHECKBOX] ? bounds.size.width : bounds.size.width/2;
        CGFloat height = bounds.size.height;
        return CGRectMake(margin, 0.0, width, height);
    }
    
    // Possibly handle CGRectZero for bounds
	// TODO: possibly make a difference here for the field.type = LABEL | TEXTFIELD
	return CGRectMake(20.0, 0.0, 50.0, 25.0);
}

- (void) alignLabel:(UILabel *)label forAlignMent:(NSString *)alignment {
	// Align the label
	if ([alignment isEqualToString:@"LEFT"]) {
		label.textAlignment = NSTextAlignmentLeft;
	} else if ([alignment isEqualToString:@"CENTER"]) {
		label.textAlignment = NSTextAlignmentCenter;
	} else if ([alignment isEqualToString:@"RIGHT"]) {
		label.textAlignment = NSTextAlignmentRight;
	}
}

- (void) applyInsetsForComponent:(MBComponent *) component{
    // Override in superclass to set a inset on the component
    // For example: component.leftInset = 10;
}

@end
