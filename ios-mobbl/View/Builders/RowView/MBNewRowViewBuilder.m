//
//  MBNewRowViewBuilder.m
//  itude-mobile-ios-app
//
//  Created by Pjotter Tommassen on 2012/3/12.
//  Copyright (c) 2012 Itude Mobile. All rights reserved.
//

#import "MBNewRowViewBuilder.h"
#import "MBComponentContainer.h"
#import "MBFieldTypes.h"
#import "MBField.h"
#import "MBFieldViewBuilderFactory.h"
#import "MBViewBuilderFactory.h"
#import "MBDevice.h"
#import "MBPanel.h"
#import "StringUtilities.h"

@implementation MBNewRowViewBuilder


- (UITableViewCell *)cellForTableView:(UITableView *)tableView withType:(NSString *)cellType style:(UITableViewCellStyle)cellstyle panel:(MBPanel *)panel {
    // First build the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellType];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:cellstyle reuseIdentifier:cellType] autorelease];
        cell.contentView.autoresizingMask= UIViewAutoresizingFlexibleWidth;
    }
    else {
        cell.accessoryView = nil;
        for(UIView *vw in cell.contentView.subviews) [vw removeFromSuperview];
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (UITableViewCell *)buildCellForRow:(MBPanel *)panel forTableView:(UITableView *)tableView {
    NSString *type = C_REGULARCELL;
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    
    // Loop through the fields in the row to determine the type and style of the cell
    for(MBComponent *child in [panel children]){
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *)child;
            // #BINCKMOBILE-19
            if ([field.definition isPreConditionValid:panel.document currentPath:[field absoluteDataPath]]) {
                
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
             
            }
        }
    }
    UITableViewCell *cell = [self cellForTableView:tableView withType:type style:style panel:panel];
    return cell;
}

- (UITableViewCell *)buildTableViewCellFor:(MBPanel *)panel forIndexPath:(NSIndexPath *)indexPath viewState:(MBViewState)viewState forTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [self buildCellForRow:panel forTableView:tableView];
    
    // Loop through the fields in the row to determine the content of the cell
    for(MBComponent *child in [panel children]){
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *)child;
            field.responder = nil;
            
            // #BINCKMOBILE-19
            if ([field.definition isPreConditionValid:panel.document currentPath:[field absoluteDataPath]]) {
                [[[MBViewBuilderFactory sharedInstance] fieldViewBuilderFactory] buildFieldView:field forParent:cell withMaxBounds:cell.bounds];
            }
        }
    }
    
//    [self addButtonsToCell:cell forRow:component];
    
    CGRect bounds = cell.bounds;
    // If the bounds are set for a field with buttons, then the view get's all messed up.
    if (![MBDevice isPad]) {
        bounds.size.width = tableView.frame.size.width;
    }
    cell.bounds = bounds;
    
    
    if (![panel outcomeName]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else  {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(CGFloat)heightForPanel:(MBPanel *)panel atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    CGFloat height = 44;
    
    // Loop through the fields in the row to determine the size of multiline text cells
    for(MBComponent *child in [panel children]){
        if ([child isKindOfClass:[MBField class]]) {
            MBField *field = (MBField *)child;
            CGFloat childHight = [self.styleHandler heightForField:field forTableView:tableView];
            
            if (childHight > height){
                height = childHight;
            }
            
        }
    }
    
    return height;
}

@end
