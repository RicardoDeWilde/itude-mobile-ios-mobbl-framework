//
//  MBDefaultRowViewBuilder.m
//  Core
//
//  Created by Wido on 24-5-10.
//  Copyright 2010 Itude Mobile BV. All rights reserved.
//

#import "MBFieldViewBuilder.h"
#import "MBViewBuilderFactory.h"
#import "MBDefaultRowViewBuilder.h"
#import "MBRow.h"
#import "MBDevice.h"
#import "MBTableViewCellConfiguratorFactory.h"
#import "MBTableViewCellConfigurator.h"

@implementation MBDefaultRowViewBuilder

- (UITableViewCell *)cellForTableView:(UITableView *)tableView withType:(NSString *)cellType
                                                            style:(UITableViewCellStyle)cellstyle
{
// First build the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellType];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:cellstyle reuseIdentifier:cellType] autorelease];
    }
    else {
        cell.accessoryView = nil;
        for(UIView *vw in cell.contentView.subviews) [vw removeFromSuperview];
    }
    return cell;
}

- (UITableViewCell *)buildCellForRow:(MBRow *)row forTableView:(UITableView *)tableView {
    NSString *type = C_REGULARCELL;
    UITableViewCellStyle style = UITableViewCellStyleDefault;

    // Loop through the fields in the row to determine the type and style of the cell
    for(MBComponent *child in [row children]){
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *)child;
            // #BINCKMOBILE-19
            if ([field.definition isPreConditionValid:row.document currentPath:[field absoluteDataPath]]) {

                if ([C_FIELD_LABEL isEqualToString:field.type] ||
                        [C_FIELD_TEXT isEqualToString:field.type]){
                    // Default
                }

                if ([C_FIELD_DROPDOWNLIST isEqualToString:field.type] ||
                        [C_FIELD_DATETIMESELECTOR isEqualToString:field.type] ||
                        [C_FIELD_DATESELECTOR isEqualToString:field.type] ||
                        [C_FIELD_TIMESELECTOR isEqualToString:field.type] ||
                        [C_FIELD_BIRTHDATE isEqualToString:field.type]) {
                    type = C_DROPDOWNLISTCELL;
                    style = UITableViewCellStyleValue1;
                }

                if ([C_FIELD_SUBLABEL isEqualToString:field.type]){
                    type = C_SUBTITLECELL;
                    style = UITableViewCellStyleSubtitle;
                }
                if ([C_FIELD_BUTTON isEqualToString:field.type] ||
                        [C_FIELD_CHECKBOX isEqualToString:field.type] ||
                        [C_FIELD_INPUT isEqualToString:field.type]||
                        [C_FIELD_USERNAME isEqualToString:field.type]||
                        [C_FIELD_PASSWORD isEqualToString:field.type]) {
                    type = field.style; // Not a mistake
                }
            }
        }
    }
    UITableViewCell *cell = [self cellForTableView:tableView withType:type style:style];
    return cell;
}

- (BOOL)rowContainsButtonField:(MBRow *)row
{
    BOOL navigable     = NO;
    for(MBComponent *child in [row children]){
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *)child;
            if ([C_FIELD_BUTTON isEqualToString:field.type]){
                navigable = YES;
            }
        }
    }
    return navigable;
}

- (void)addButtonsToCell:(UITableViewCell *)cell forRow:(MBRow *)row
{
    NSMutableArray *buttons = nil;
    NSString *fieldstyle = nil;
    for (MBComponent *child in [row children]) {
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *) child;
            if ([field.definition isPreConditionValid:row.document currentPath:[field absoluteDataPath]]) {
                if ([C_FIELD_BUTTON isEqualToString:field.type]){
                    if ([C_FIELD_STYLE_NETWORK isEqualToString:[field style]]) {
                        UIView *buttonView = [[[MBViewBuilderFactory sharedInstance] fieldViewBuilder]  buildButton:field withMaxBounds:CGRectZero];
                        [field setResponder:buttonView];
                        if (buttons == nil) {
                            buttons = [[[NSMutableArray alloc]initWithObjects:buttonView,nil] autorelease];
                        }else {
                            [buttons addObject:buttonView];
                        }
                    }
                    if ([C_FIELD_STYLE_NAVIGATION isEqualToString:[field style]]) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.accessoryView.isAccessibilityElement = YES;
                        cell.accessoryView.accessibilityLabel = @"DisclosureIndicator";
                    }
                    fieldstyle = [field style];
                }
            }
        }
    }

    if ([self rowContainsButtonField:row]) {
        if ([C_FIELD_STYLE_NETWORK isEqualToString:fieldstyle] && [buttons count] > 0) {

            CGRect buttonsFrame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            UIView *buttonsView = [[[UIView alloc] initWithFrame:buttonsFrame] autorelease];
            // Let the width of the view resize to the parent view to reposition any buttons
            buttonsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            // Disabled: row is not a MBPanel, will probably crash
            //[[[MBViewBuilderFactory sharedInstance] styleHandler] applyStyle:buttonsView panel:(MBPanel *)row viewState:viewState];
            buttonsFrame = buttonsView.frame;

            CGFloat spaceBetweenButtons = 10;
            NSUInteger buttonXposition = (NSUInteger) buttonsFrame.size.width;
            for (UIView *button in buttons) {
                CGRect buttonFrame = button.frame;
                buttonXposition -= buttonFrame.size.width;
                buttonFrame.origin.x = buttonXposition;
                buttonFrame.origin.y = (NSUInteger) (buttonsFrame.size.height - buttonFrame.size.height) / 2;
                button.frame = buttonFrame;
                // Make sure that when the parent view resizes, the buttons get repositioned as wel
                button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

                [buttonsView addSubview:button];
                buttonXposition -= spaceBetweenButtons;
            }

            [cell.contentView addSubview:buttonsView];

            // Don't make the cell selectable because the buttons will handle the action
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        //set a default selecitonStyle, selection style can be overwritten by subclass but useful if subclass changes its value
        else if ([C_FIELD_STYLE_NAVIGATION isEqualToString:fieldstyle]) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else if ([C_FIELD_STYLE_POPUP isEqualToString:fieldstyle]) {
            // A popUp does not navigate so, don't make the cell selectable
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}


- (UITableViewCell *)buildRowView:(MBRow *)row forIndexPath:(NSIndexPath *)indexPath viewState:(MBViewState)viewState
                     forTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [self buildCellForRow:row forTableView:tableView];

    // Loop through the fields in the row to determine the content of the cell
    MBTableViewCellConfiguratorFactory *configuratorFactory = [[MBTableViewCellConfiguratorFactory alloc]
            initWithStyleHandler:self.styleHandler];
    for(MBComponent *child in [row children]){
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *)child;
            field.responder = nil;

            // #BINCKMOBILE-19
            if ([field.definition isPreConditionValid:row.document currentPath:[field absoluteDataPath]]) {

                MBTableViewCellConfigurator *cellConfigurator = [configuratorFactory configuratorForFieldType:field.type];
                [cellConfigurator configureCell:cell withField:field];
            }
        }
    }
    [configuratorFactory release];

    [self addButtonsToCell:cell forRow:row];

    CGRect bounds = cell.bounds;
    // If the bounds are set for a field with buttons, then the view get's all messed up.
    if (![MBDevice isPad] && ![self rowContainsButtonField:row]) {
        bounds.size.width = tableView.frame.size.width;
    }
    cell.bounds = bounds;

    if (![self rowContainsButtonField:row]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end
