//
//  SettingsTextField.m
//  iSugarCRM
//
//  Created by pramati on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextFieldTableCell.h"
#define kiPadFontSize       24
#define kMinLabelWidth      97
#define kMargin             5
#define kiPadLableMargin    25

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
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect labelFrame = label.frame;
        labelFrame.origin.x += kiPadLableMargin ;
        label.frame = labelFrame;
        label.font = [UIFont systemFontOfSize:kiPadFontSize];
        textField.font = [UIFont systemFontOfSize:kiPadFontSize];
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
