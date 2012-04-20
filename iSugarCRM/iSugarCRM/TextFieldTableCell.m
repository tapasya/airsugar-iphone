//
//  SettingsTextField.m
//  iSugarCRM
//
//  Created by pramati on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextFieldTableCell.h"
#define kiPadFontSize       20
#define kMinLabelWidth      97
#define kMargin             5
#define kiPadLableMargin    45

@implementation TextFieldTableCell
@synthesize label;
@synthesize textField;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize labelSize = [label sizeThatFits:CGSizeZero];
    if(IS_IPAD)
    {
        CGRect labelFrame = label.frame;
        if(labelFrame.origin.x - kiPadLableMargin <= 0)
        {
          labelFrame.origin.x += kiPadLableMargin ;  
        }        
        label.frame = labelFrame;
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:kiPadFontSize];
        textField.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kiPadFontSize-2];
    }
	labelSize.width = MIN(labelSize.width, label.bounds.size.width);
    
    CGRect textFieldFrame = textField.frame;
	textFieldFrame.origin.x = label.frame.origin.x +  MAX(kMinLabelWidth, labelSize.width) + kMargin ;
	if (!label.text.length)
		textFieldFrame.origin.x = label.frame.origin.x;
	textFieldFrame.size.width = textField.superview.frame.size.width - textFieldFrame.origin.x - label.frame.origin.x;
	textField.frame = textFieldFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
