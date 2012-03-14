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
#import "DataObject.h"

#define kSideMargin 5.0
#define kLabelWidth 150.0
#define KCellHeight 50.0
#define kHeightlMargin 30.0
@interface EditViewController()
@property(strong) UITableView *_tableView;
@property(strong) NSArray *dataSource;
@property(strong) NSArray *_detailedData;
@end

@implementation EditViewController
@synthesize _tableView;
@synthesize dataSource;
@synthesize metadata;
@synthesize _detailedData;


#pragma mark - View lifecycle

+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata{

    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.metadata = metadata;
    return editViewController;

}

+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata andDetailedData:(NSArray *)detailedData{
    
    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.metadata = metadata;
    editViewController._detailedData = detailedData;
    return editViewController;
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
   _tableView = [[UITableView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.view = _tableView;
    //[self.view addSubview:_tableView];
}



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveRecord)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    UIBarButtonItem *discardButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStyleDone target:self action:@selector(discard)];
    self.navigationItem.leftBarButtonItem = discardButtonItem;

}

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

-(void)saveRecord{
    //TODO save data into DB and update the same on server
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) discard
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"NUMBER OF FIELDS IN EDIT/ADD %i",[[metadata.fields allObjects] count]);
    return [[metadata.fields allObjects] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UILabel *fieldLabel = [[UILabel alloc] init];
        fieldLabel.font = [UIFont boldSystemFontOfSize:15];
        fieldLabel.tag = 1001;
        fieldLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:fieldLabel];
        UITextField *valueField = [[UITextField alloc] init];
        valueField.borderStyle = UITextBorderStyleRoundedRect;
        valueField.tag = 1002;
        [cell.contentView addSubview:valueField];
        valueField.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UILabel *fieldLabel = (UILabel*)[cell.contentView viewWithTag:1001];
    DataObjectField *field = [[[self.metadata fields] allObjects] objectAtIndex:indexPath.row];
    fieldLabel.text = field.label;
    fieldLabel.textAlignment = UITextAlignmentLeft;
    fieldLabel.numberOfLines = 0;
    fieldLabel.lineBreakMode = UILineBreakModeWordWrap;
    fieldLabel.frame = CGRectMake(kSideMargin, 0,cell.contentView.frame.size.width/2 - 30,cell.contentView.frame.size.height);
    
    
    UITextField *valueField = (UITextField*)[cell.contentView viewWithTag:1002];
    if(_detailedData != nil){
        NSString *value = [(DataObject *)[_detailedData objectAtIndex:0] objectForFieldName:field.name];
        valueField.text = value;
    }else{
        valueField.text = @"";
    }
    valueField.font = [UIFont systemFontOfSize:15];
    valueField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    valueField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    valueField.frame = CGRectMake(cell.contentView.frame.origin.x+cell.contentView.frame.size.width/2-22, 5, cell.contentView.frame.size.width/2+20 , cell.contentView.frame.size.height-10);
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
