//
//  EditViewRowItem.m
//  iSugarCRM
//
//  Created by dayanand on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditViewRowItem.h"
#define kSideMargin 5.0
#define kLabelWidth 150.0
#define KCellHeight 50.0
#define kHeightlMargin 30.0
@interface EditViewRowItem()
    -(NSString *)formatDate:(NSString *)dateValue withFormat:(NSString *)dateFormat;
@end

@implementation EditViewRowItem


@synthesize label;
@synthesize value;
@synthesize action;
@synthesize type;
@synthesize delegate;


-(CGFloat)heightForCell:(UITableView*)tableView
{
    NSLog(@"%@",self.label);
    return 40.0f;
}


-(UITableViewCell*)reusableCellForTableView:(UITableView*)tableView{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:[self reusableCellIdentifier]];
    UITextField *valueField;
    UILabel* fieldLabel;
    
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reusableCellIdentifier]];
        fieldLabel = [[UILabel alloc] init];
        fieldLabel.text = self.label;
        [fieldLabel setFont:[UIFont boldSystemFontOfSize:15]];
        fieldLabel.tag = 1000;
        fieldLabel.textAlignment = UITextAlignmentLeft;
        fieldLabel.numberOfLines = 0;
        fieldLabel.lineBreakMode = UILineBreakModeWordWrap;
        fieldLabel.frame = CGRectMake(kSideMargin, 0,cell.contentView.frame.size.width/2 - 30,cell.contentView.frame.size.height);
        fieldLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:fieldLabel];
        
        if ([[self reusableCellIdentifier] isEqualToString:@"phone"]) {
            valueField = [[UITextField alloc] init];
            valueField.borderStyle = UITextBorderStyleRoundedRect;
            valueField.tag = 1001;
            valueField.delegate = self.delegate;
            valueField.keyboardType = UIKeyboardTypePhonePad;
            valueField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
            valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:valueField];
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"number"]) {
            valueField = [[UITextField alloc] init];
            valueField.borderStyle = UITextBorderStyleRoundedRect;
            valueField.tag = 1001;
            valueField.delegate = self.delegate;
            valueField.keyboardType = UIKeyboardTypeNumberPad;
            valueField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
            valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:valueField];
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"url"]) {
            valueField = [[UITextField alloc] init];
            valueField.borderStyle = UITextBorderStyleRoundedRect;
            valueField.tag = 1001;
            valueField.delegate = self.delegate;
            valueField.keyboardType = UIKeyboardTypeURL;
            valueField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
            valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:valueField];
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"email"]) {
            valueField = [[UITextField alloc] init];
            valueField.borderStyle = UITextBorderStyleRoundedRect;
            valueField.delegate = self.delegate;
            valueField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            valueField.tag = 1001;
            valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
            valueField.keyboardType = UIKeyboardTypeEmailAddress;
            valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:valueField];
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"date"]) {
            UILabel *valueField = [[UILabel alloc] init];
            valueField.tag = 1001;
            valueField.backgroundColor = [UIColor clearColor];
            valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
            valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:valueField];
        }else{
            valueField = [[UITextField alloc] init];
            valueField.borderStyle = UITextBorderStyleRoundedRect;
            valueField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            valueField.tag = 1001;
            valueField.delegate = self.delegate;
            valueField.keyboardType = UIKeyboardTypeDefault;
            valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
            valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:valueField];
        }
    }
    fieldLabel = (UILabel*)[cell.contentView viewWithTag:1000];
    
    [fieldLabel setFont:[UIFont boldSystemFontOfSize:15]];
    fieldLabel.text = self.label;
    fieldLabel.textAlignment = UITextAlignmentLeft;
    fieldLabel.numberOfLines = 0;
    fieldLabel.lineBreakMode = UILineBreakModeWordWrap;
    fieldLabel.frame = CGRectMake(kSideMargin, 0,cell.contentView.frame.size.width/2 - 30,cell.contentView.frame.size.height);
    if ([[self reusableCellIdentifier] isEqualToString:@"phone"]) {
        valueField = (UITextField*)[cell.contentView viewWithTag:1001];
        valueField.delegate = self.delegate;
        valueField.text = [self value];
    }else if ([[self reusableCellIdentifier] isEqualToString:@"number"]) {
        valueField = (UITextField*)[cell.contentView viewWithTag:1001];
        valueField.delegate = self.delegate;
        valueField.text = [self value];
    }else if ([[self reusableCellIdentifier] isEqualToString:@"url"]) {
        valueField = (UITextField*)[cell.contentView viewWithTag:1001];
        valueField.delegate = self.delegate;
        valueField.text = [self value];
    }else if ([[self reusableCellIdentifier] isEqualToString:@"email"]) {
        valueField = (UITextField*)[cell.contentView viewWithTag:1001];
        valueField.delegate = self.delegate;
        valueField.text = [self value];
    }else if ([[self reusableCellIdentifier] isEqualToString:@"date"]) {
        NSString *dateString = [self formatDate:[self value] withFormat:nil];
        UILabel *valueField = (UILabel*)[cell.contentView viewWithTag:1001];
        valueField.text = dateString;
        valueField.backgroundColor = [UIColor clearColor];
    }else {
        valueField = (UITextField*)[cell.contentView viewWithTag:1001];
        valueField.delegate = self.delegate;
        valueField.text = [self value];
    }
    return cell;
}

-(NSString*)reusableCellIdentifier
{
    if(![action isEqualToString:@""])
    {
        return [self action];
        
    } else {
        return [[self class]description];
    }
}

-(NSString *)formatDate:(NSString *)dateValue withFormat:(NSString *)dateFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (dateFormat == nil) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }else{
        [dateFormatter setDateFormat:dateFormat];
    }
    
    NSDate *date = [dateFormatter dateFromString:dateValue];
    NSLog(@"date object from string is %@",date);
    if (date != nil) {
        [dateFormatter setDateFormat:@"MM/dd/yy"];
        dateValue = [dateFormatter stringFromDate:date];
        NSLog(@"dateValue is %@",dateValue);
    }else{
        [dateFormatter setDateFormat:@"MM/dd/yy"];
        dateValue = [dateFormatter stringFromDate:[NSDate date]];
    }
    return dateValue;
}
@end
