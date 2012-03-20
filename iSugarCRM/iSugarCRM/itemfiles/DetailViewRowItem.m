
//  Created by Ved Surtani on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewRowItem.h"
#define kSideMargin 8.0
#define kLabelWidth 150.0
#define KCellHeight 50.0
#define kHeightlMargin 30.0
@interface DetailViewRowItem ()
-(NSString*)valueStringWithFormat:(NSString*)format;
@end
@implementation DetailViewRowItem
@synthesize label,values,action,type;

-(CGFloat)heightForCell:(UITableView*)tableView
{
  //  NSLog(@"%@",self.label);
    CGFloat height = [[self valueStringWithFormat:nil] sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(tableView.frame.size.width - [self.label sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(170,1000) lineBreakMode:UILineBreakModeWordWrap].width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    return KCellHeight>height?KCellHeight:(height+kHeightlMargin);
}

//TODO use OHALabel and NSAttributedString
//TODO format fields according to the type
-(UITableViewCell*)reusableCellForTableView:(UITableView*)tableView{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:[self reusableCellIdentifier]];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self reusableCellIdentifier]];
        UILabel* label_ = [[UILabel alloc] init];
        [label_ setFont:[UIFont boldSystemFontOfSize:18]];
        label_.tag = 1000;
        [cell.contentView addSubview:label_];
        UILabel* textLabel = [[UILabel alloc] init];
        textLabel.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        textLabel.numberOfLines = 0;
        [textLabel setFont:[UIFont boldSystemFontOfSize:18]];
        textLabel.tag = 1001;
        textLabel.numberOfLines = 0;
        [cell.contentView addSubview:textLabel];
        
        if ([[self reusableCellIdentifier] isEqualToString:@"phone"]) {
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.tag = 1002;
            [actionButton addTarget:self action:@selector(actionHandler:) forControlEvents:UIControlEventTouchUpInside];
            actionButton.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actionButton];
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"url"]) {
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.tag = 1002;
            [actionButton addTarget:self action:@selector(actionHandler:) forControlEvents:UIControlEventTouchUpInside];
            actionButton.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actionButton];
            
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"email"]) {
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.tag = 1002;
            [actionButton addTarget:self action:@selector(actionHandler:) forControlEvents:UIControlEventTouchUpInside];
            actionButton.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actionButton];
            
        }
        else if ([[self reusableCellIdentifier] isEqualToString:@"date"]) {
            UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            actionButton.tag = 1002;
            [actionButton addTarget:self action:@selector(actionHandler:) forControlEvents:UIControlEventTouchUpInside];
            actionButton.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actionButton];
        }
    }
    
    UILabel* textLabel = (UILabel*)[cell.contentView viewWithTag:1000];
    
    [textLabel setFont:[UIFont boldSystemFontOfSize:18]];
    textLabel.text = [NSString stringWithFormat:@"%@: ",[self label]];
    textLabel.frame = CGRectMake(kSideMargin, 0,[self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width + 2*kSideMargin,50);
    textLabel = (UILabel*)[cell.contentView viewWithTag:1001];
    [textLabel setFont:[UIFont systemFontOfSize:18]];
    
    textLabel.frame = CGRectMake([self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+2*kSideMargin, 0, cell.contentView.frame.size.width- ([self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+2*kSideMargin) , cell.contentView.frame.size.height);    
    
    if (![[self valueStringWithFormat:nil] isEqualToString:@"NA"]) {
        
        if ([[self reusableCellIdentifier] isEqualToString:@"phone"]) {
            textLabel.text = [self valueStringWithFormat:nil];
            UIButton *button = (UIButton*)[cell.contentView viewWithTag:1002];
            button.frame = CGRectMake(kSideMargin+[self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width +kSideMargin, 0, cell.contentView.frame.size.width - [self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width-kSideMargin, cell.contentView.frame.size.height);
        } else if ([[self reusableCellIdentifier] isEqualToString:@"url"]) {
            textLabel.text = [self valueStringWithFormat:nil];
            UIButton *button = (UIButton*)[cell.contentView viewWithTag:1002];
            button.frame = CGRectMake(kSideMargin+[self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+kSideMargin, 0, cell.contentView.frame.size.width - [self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width-kSideMargin, cell.contentView.frame.size.height);
        } else if ([[self reusableCellIdentifier] isEqualToString:@"email"]) {
            textLabel.text = [self valueStringWithFormat:nil];
            UIButton *button = (UIButton*)[cell.contentView viewWithTag:1002];
            button.frame = CGRectMake(kSideMargin+[self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+kSideMargin, 0, cell.contentView.frame.size.width - [self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width-kSideMargin, cell.contentView.frame.size.height);
        } else if ([[self reusableCellIdentifier] isEqualToString:@"date"]) {
            NSString *dateString = [self valueStringWithFormat:nil];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [dateFormatter dateFromString:dateString];
            [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
            dateString = [dateFormatter stringFromDate:date];
            
            textLabel.text = dateString;
            UIButton *button = (UIButton*)[cell.contentView viewWithTag:1002];
            button.frame = CGRectMake(kSideMargin+[self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+kSideMargin, 0, cell.contentView.frame.size.width - [self.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width-kSideMargin, cell.contentView.frame.size.height);
        } else {
            textLabel.text = [self valueStringWithFormat:nil];
        }
    } else {
        textLabel.text = [self valueStringWithFormat:nil];
        textLabel.font = [UIFont italicSystemFontOfSize:16];
    }
    return cell;
    
}
-(NSString*)valueStringWithFormat:(NSString*)format
{
    NSMutableString *displayString;
    if ([format rangeOfString:@"$"].length>0) {
        
        displayString = [NSMutableString stringWithFormat:@"%@: ",label];
    }
    else displayString =  [NSMutableString stringWithString:@""];
    int count = 0;
    
    NSMutableString *valueString = [NSMutableString stringWithString:@""];
    for(NSString *value in values)
    {
        count++;
        if (value == nil || [value isEqualToString:@""]) {
            continue;
        }
        if (count==[values count]) {
            [valueString appendString:[NSString stringWithFormat:@"%@ ",value]];
        }
        else {
            [valueString appendString:[NSString stringWithFormat:@"%@, ",value]];
        }
    }
    if ([valueString isEqualToString:@""]) {
        [displayString appendString:@"NA"];
    }
    else{
        [displayString appendString:valueString];
    }
    
    return displayString;
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
-(void)actionHandler:(id)sender{
    if ([action isEqualToString:@"phone"]) {
        NSMutableString *phone = [[self valueStringWithFormat:nil] mutableCopy];
        [phone replaceOccurrencesOfString:@" " 
                               withString:@"" 
                                  options:NSLiteralSearch 
                                    range:NSMakeRange(0, [phone length])];
        [phone replaceOccurrencesOfString:@"(" 
                               withString:@"" 
                                  options:NSLiteralSearch 
                                    range:NSMakeRange(0, [phone length])];
        [phone replaceOccurrencesOfString:@")" 
                               withString:@"" 
                                  options:NSLiteralSearch 
                                    range:NSMakeRange(0, [phone length])];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
        [[UIApplication sharedApplication] openURL:url];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phone]]];
    }
    else if ([action isEqualToString:@"date"]) {
        return;
    }
    else if ([action isEqualToString:@"email"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[self valueStringWithFormat:nil]]]];  
    } 
    else if ([action isEqualToString:@"url"]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",[[self valueStringWithFormat:nil]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]];
    }
    else if ([action isEqualToString:@"map"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"url:%@",[self valueStringWithFormat:nil]]]];
    }
    
    else {
        return;
    }    
    
}
@end
