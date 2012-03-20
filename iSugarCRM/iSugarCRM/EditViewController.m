//
//  EditViewController.m
//  iSugarCRM
//
//  Created by dayanand on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "DataObjectField.h"
#import "EditViewController.h"
#import "DataObjectMetadata.h"
#define kSideMargin 8.0
#define kLabelWidth 150.0
#define KCellHeight 50.0
#define kHeightlMargin 30.0
@interface EditViewController()
@property(strong) UITableView *_tableView;
@property(strong) NSArray *dataSource;
@end

@implementation EditViewController
@synthesize _tableView;
@synthesize dataSource;
@synthesize metadata;


#pragma mark - View lifecycle

+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata{

    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.metadata = metadata;
    return editViewController;

}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
   _tableView = [[UITableView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.view = _tableView;
    //[self.view addSubview:_tableView];
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - TableView DataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"NUMBER OF FIELDS IN EDIT/ADD %i",[[metadata.fields allObjects] count]); //remove
    return [[metadata.fields allObjects] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UILabel *fieldLabel = [[UILabel alloc] init];
        fieldLabel.font = [UIFont boldSystemFontOfSize:18];
        fieldLabel.tag = 1001;
        [cell.contentView addSubview:fieldLabel];
        UITextField *valueField = [[UITextField alloc] init];
        valueField.borderStyle = UITextBorderStyleBezel;
        valueField.tag = 1002;
        [cell.contentView addSubview:valueField];
        valueField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *fieldLabel = (UILabel*)[cell.contentView viewWithTag:1001];
    DataObjectField *field = [[[self.metadata fields] allObjects] objectAtIndex:indexPath.row];
    fieldLabel.text = field.label;
    fieldLabel.frame = CGRectMake(kSideMargin, 0,[field.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width + 2*kSideMargin,cell.contentView.frame.size.height);
    //
 UITextField *valueField = (UITextField*)[cell.contentView viewWithTag:1002];
    valueField.frame = CGRectMake([field.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+2*kSideMargin, 0, cell.contentView.frame.size.width- ([field.label sizeWithFont:[UIFont boldSystemFontOfSize:18]].width+2*kSideMargin) , cell.contentView.frame.size.height);
    valueField.delegate = self;
    return cell;
}
#pragma mark - TableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - TextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
