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
#import "SyncHandler.h"
#import "UITableViewCellItem.h"
#import "EditViewRowItem.h"
#import "AppDelegate.h"
#import "EditViewSectionItem.h"
#import "SyncHandler.h"

#define kSideMargin 5.0
#define kLabelWidth 150.0
#define KCellHeight 50.0
#define kHeightlMargin 30.0
#define kPrevSegementItemIndex 0
#define kNextSegementItemIndex 1
@interface EditViewController ()
@property(strong) UITableView *_tableView;
@property(strong) NSMutableDictionary *dataSource;
@property(strong) NSArray *detailedData;


@property(strong) NSMutableArray *editableDataObjectFields;
@property(nonatomic,strong) UIToolbar *toolBar;
@property(nonatomic,strong) UIDatePicker *pickerView;
@property(strong) UIActionSheet *actionSheet;

-(void)registerForKeyboardNotifications;
-(void)unRegisterForKeyboardNotifications;
-(void)dismissPickerView;
-(CGRect)toolBarFrame;
-(CGRect)pickerViewFrame;
-(void)arrangeViews:(UIInterfaceOrientation)orientation;
-(void)scrollCell:(UITableViewCell*)cell;
-(NSInteger)effectiveRowIndexWithIndexPath:(NSIndexPath *)indexpath;
-(BOOL)hasNext:(NSIndexPath *)indexPath;
-(BOOL)hasPrevious:(NSIndexPath *)indexPath;
-(NSInteger)totalRowsCount;

@end

@implementation EditViewController
@synthesize _tableView;
@synthesize dataSource;
@synthesize metadata;
@synthesize detailedData;
@synthesize editableDataObjectFields;
@synthesize toolBar;
@synthesize pickerView;
@synthesize actionSheet;
//@synthesize detailedData;



#pragma mark - View lifecycle

+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata{

    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.metadata = metadata;
    return editViewController;

}

+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata andDetailedData:(NSMutableArray *)detailedData{
    
    EditViewController *editViewController = [[EditViewController alloc] init];
    editViewController.metadata = metadata;
    editViewController.detailedData = detailedData;
    return editViewController;
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat width = mainFrame.size.width;
    CGFloat height = mainFrame.size.height;
    //_tableView = [[UITableView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,width, height)];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [self.view setAutoresizesSubviews:YES];
}



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveRecord)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    UIBarButtonItem *discardButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStylePlain target:self action:@selector(discard)];
    self.navigationItem.leftBarButtonItem = discardButtonItem;
    [self performSelectorOnMainThread:@selector(getEditableDataObjectFieldArray) withObject:nil waitUntilDone:NO];
    
    for (UIView * subview in self.pickerView.subviews) {
        subview.frame = pickerView.bounds;
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [self registerForKeyboardNotifications];
    [self arrangeViews:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [self unRegisterForKeyboardNotifications];
}

-(void)getEditableDataObjectFieldArray{
    NSArray *dataObjectFields = [metadata.fields allObjects];
    editableDataObjectFields = [[NSMutableArray alloc] init];
    NSMutableArray *mandatoryFields = [[NSMutableArray alloc] init];
    NSMutableArray *optionalFields = [[NSMutableArray alloc] init];
    EditViewSectionItem *mandatorySection = [[EditViewSectionItem alloc]init];
    EditViewSectionItem *optionalSection = [[EditViewSectionItem alloc]init];
    dataSource = [[NSMutableDictionary alloc] init];
    DataObject *dataObject = (DataObject *)[detailedData objectAtIndex:0];
    for (DataObjectField *dof in dataObjectFields) {
        if (dof.editable == TRUE){
            if(dataObject){
                [dataSource setObject:[dataObject objectForFieldName:dof.name] forKey:dof.name];
            }
            if (dof.mandatory == TRUE) {
                [mandatoryFields addObject:dof];
            }else{
                [optionalFields addObject:dof];
            }
        }
    }
    mandatorySection.sectionTitle = @"Required";
    mandatorySection.rowItems = mandatoryFields;
    optionalSection.sectionTitle = @"Optional";
    optionalSection.rowItems = optionalFields;
    [editableDataObjectFields addObject:mandatorySection];
    [editableDataObjectFields addObject:optionalSection];
    [_tableView reloadData];
}

- (void)viewDidUnload
{
    dataSource = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //When application goes to background in Landscapemode and user relaunches in potraitmode(viceversa also) should clear if there is any contentInset set to the tableview
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    _tableView.contentInset =  UIEdgeInsetsZero;
    [self arrangeViews: toInterfaceOrientation];
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndexPath];
    if ([cell.reuseIdentifier isEqualToString:@"date"]) {
        toolBar.frame = CGRectMake(0,_tableView.frame.size.height-pickerView.frame.size.height-35,pickerView.frame.size.width,35);
    }
}

- (void) arrangeViews: (UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        pickerView.frame = CGRectMake(0, 200, 320, 216);
    }
    else {
        pickerView.frame = CGRectMake(0, 106, 480, 162);
    }
}

-(void)saveRecord{
    //TODO save data into DB and update the same on server
    DataObject *dataObject = (DataObject *)[detailedData objectAtIndex:0];
    for (NSString *key in [dataSource allKeys]) {
        [dataObject setObject:[dataSource objectForKey:key] forFieldName:key];
    }
    SyncHandler * syncHandler = [SyncHandler sharedInstance];
    NSLog(@"module name = %@", self.metadata.objectClassIdentifier);
    //[self.navigationController dismissModalViewControllerAnimated:YES];
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate showWaitingAlertWithMessage:@"Please wait syncing"];
    [syncHandler uploadData:[NSArray arrayWithObject:[self.detailedData objectAtIndex:0]] forModule:self.metadata.objectClassIdentifier parent:self];
}

-(void) discard
{
    dataSource = nil;
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource methods
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.editableDataObjectFields count];
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [editableDataObjectFields count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[editableDataObjectFields objectAtIndex:section] rowItems] count];
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [[editableDataObjectFields objectAtIndex:section] sectionTitle];
    return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:indexPath.section];
    DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:indexPath.row];
    EditViewRowItem *evRowItem = [[EditViewRowItem alloc] init];
    evRowItem.label = dof.label;
    evRowItem.action = dof.action;
    evRowItem.delegate = self;
    if(detailedData != nil){
        //evRowItem.value = [(DataObject *)[_detailedData objectAtIndex:0] objectForFieldName:dof.name];
        evRowItem.value = [dataSource objectForKey:dof.name];
    }
    else{
        evRowItem.value = @"";

    }
    return [evRowItem reusableCellForTableView:tableView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:indexPath.section];
    DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:indexPath.row];
    EditViewRowItem *evRowItem = [[EditViewRowItem alloc] init];
    evRowItem.label = dof.label;
    evRowItem.action = dof.action;
    if(detailedData != nil){
        evRowItem.value = [(DataObject *)[detailedData objectAtIndex:0] objectForFieldName:dof.name];
    }
    else{
        evRowItem.value = @"";
    }
    return [evRowItem heightForCell:(UITableView*)tableView];
}

#pragma mark - TableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndexPath = indexPath;
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:@"date"])
    {
        UILabel *valueField = (UILabel*)[cell.contentView viewWithTag:1001];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        self.pickerView.date = [dateFormatter dateFromString:valueField.text];
        [self.view endEditing:YES]; // resign firstResponder if you have any text fields so the keyboard doesn't get in the way
        [self._tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES]; // Scroll your row to the top so the user can actually see the row when interacting with the pickerView
        
        // Pickerview setup
        self.pickerView.frame = CGRectZero;
        // place the pickerView outside the screen boundaries
        self.pickerView.frame = CGRectMake(0, 500, pickerView.frame.size.width,pickerView.frame.size.height);
        // set it to visible and then animate it to slide up
        [self.pickerView setHidden:NO];
        [UIView beginAnimations:nil context:nil];
        self.pickerView.frame = [self pickerViewFrame];
        self.toolBar.frame = CGRectMake(0, _tableView.frame.size.height-pickerView.frame.size.height-self.toolBar.frame.size.height,self.view.bounds.size.width,35);
        self.toolBar.alpha = 1.0;
        [self.view addSubview:self.toolBar];
        [self.view addSubview:pickerView];
        [UIView commitAnimations];
        [self scrollCell:cell];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
#pragma mark - TextField delegate methods
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self dismissPickerView];
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    [self scrollCell:cell];
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:selectedIndexPath.section];
    DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:selectedIndexPath.row];
    [dataSource setObject:textField.text forKey:dof.name];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    _tableView.contentInset =  UIEdgeInsetsZero;
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionBottom animated:YES ];
    return YES;
}

#pragma mark SyncHandler Delegate

-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate dismissWaitingAlert];
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:error waitUntilDone:NO];
}
-(void)syncComplete:(SyncHandler*)syncHandler{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate dismissWaitingAlert];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:nil waitUntilDone:NO];
}

-(IBAction)showSyncAlert:(id)sender
{
    NSError* error = (NSError*) sender;
    if(error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sync Completed" message:@"Sync Completed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//register for keyboard notifications.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

//unregister for keyboard notifications.
- (void)unRegisterForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    kbBeginSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.toolBar.alpha = 1.0;
    toolBar.frame=[self toolBarFrame];
    [self.view addSubview:toolBar];
}
-(void)keyboardWillBeHidden:(NSNotification *)notification
{
    toolBar.alpha = 0.0;
    toolBar.frame = CGRectMake(0,500,self.toolBar.frame.size.width,self.toolBar.frame.size.height);
    _tableView.contentInset = UIEdgeInsetsZero;
}
-(CGRect)toolBarFrame
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndexPath];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        if ([cell.reuseIdentifier isEqualToString:@"date"]){
            return CGRectMake(0, _tableView.frame.size.height-pickerView.frame.size.height-toolBar.frame.size.height,self.view.bounds.size.height,35);
        }else{
            return CGRectMake(0, _tableView.frame.size.height-kbBeginSize.width-toolBar.frame.size.height,self.view.bounds.size.width, toolBar.frame.size.height);
        }
    }
    else
    {
        if ([cell.reuseIdentifier isEqualToString:@"date"]) {
            return CGRectMake(0, _tableView.frame.size.height-pickerView.frame.size.height-toolBar.frame.size.height,self.view.bounds.size.width,toolBar.frame.size.height);
        }else{
            return CGRectMake(0,_tableView.frame.size.height-kbBeginSize.height-toolBar.frame.size.height,self.view.bounds.size.width,toolBar.frame.size.height);
        }
    }
}

-(CGRect)pickerViewFrame
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        return CGRectMake(0, 106, 480, 162);
    }
    else
    {   
        return CGRectMake(0, 200, 320, 216);
    }
}

-(UIDatePicker*) pickerView
{
    if(!pickerView){
        pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
        //pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [pickerView setDatePickerMode:UIDatePickerModeDate];
        [pickerView setBackgroundColor:[UIColor clearColor]];
        [pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return pickerView;
}
-(UIToolbar *) toolBar
{
    if(toolBar == nil)
    {
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,35)];
        toolBar.barStyle = UIBarStyleBlackTranslucent;
        toolBar.tintColor = [UIColor darkGrayColor];
        toolBar.barStyle = UIBarStyleBlackTranslucent;
        toolBar.tintColor = [UIColor darkGrayColor];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)];
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:nil];
        control.momentary = YES;
        [control insertSegmentWithTitle:@"Previous" atIndex:kPrevSegementItemIndex animated:YES];
        [control insertSegmentWithTitle:@"Next" atIndex:kNextSegementItemIndex animated:YES];
        control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.tintColor = [UIColor darkGrayColor];
        control.momentary = YES;
        [control addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged];			
        UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
        
        NSArray *items = [[NSArray alloc] initWithObjects:controlItem, flex, barButtonItem, nil];
        [toolBar setItems:items];
    }
    return toolBar;
}

-(void)dismissKeyboard:(id)sender
{
    _tableView.contentInset = UIEdgeInsetsZero;
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndexPath];
    if([cell.reuseIdentifier isEqualToString:@"date"]){
        toolBar.alpha = 0.0;
        [self dismissPickerView];
    }else{
        toolBar.alpha = 0.0;
        toolBar.frame = CGRectMake(0,500,self.toolBar.frame.size.width,self.toolBar.frame.size.height);
        [self.view endEditing:YES];
    }
}
-(void)dismissPickerView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.pickerView.frame = CGRectMake(0, 500, pickerView.frame.size.width,pickerView.frame.size.height); // place the pickerView outside the screen
    [pickerView removeFromSuperview];
    [UIView commitAnimations];
}

- (void)dateChanged:(id)sender
{
	UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndexPath];
    UILabel *dateValue = (UILabel *)[cell.contentView viewWithTag:1001];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
	dateValue.text = [dateFormatter stringFromDate:self.pickerView.date];
    NSLog(@"DATE VALUE %@",dateValue.text);
    NSLog(@"pikerview date %@",pickerView.date);
    EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:selectedIndexPath.section];
    DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:selectedIndexPath.row];
    NSDate *date = pickerView.date;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
	[(DataObject *)[detailedData objectAtIndex:0] setObject:[dateFormatter stringFromDate:date] forFieldName:dof.name];
}

-(void)nextPrevious:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger segItemIndex =  segmentedControl.selectedSegmentIndex;
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndexPath];
    switch (segItemIndex) {
        case kPrevSegementItemIndex:
            //if(selectedIndexPath.row >= 0){
            if([self hasPrevious:selectedIndexPath])
            {
                NSIndexPath* newIndexPath;
                if(selectedIndexPath.section !=0){
                    if(selectedIndexPath.row !=0){
                        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row-1 inSection:selectedIndexPath.section];
                    }else{
                        newIndexPath = [NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:selectedIndexPath.section-1]-1 inSection:selectedIndexPath.section-1];
                    }
                }else{
                    if(selectedIndexPath.row !=0){
                        newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row-1 inSection:selectedIndexPath.section];
                    }else{
                        return;
                    }
                }
                selectedIndexPath = newIndexPath;
                if([cell.reuseIdentifier isEqualToString:@"date"])
                {
                    UITableViewCell *nextCell = [_tableView cellForRowAtIndexPath:newIndexPath];
                    [self scrollCell:nextCell];//ScrollCell
                    
                    if ([nextCell.reuseIdentifier isEqualToString:@"date"])
                    {
                        UILabel *valueField = (UILabel*)[nextCell.contentView viewWithTag:1001];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                        if(valueField.text != nil)
                            self.pickerView.date = [dateFormatter dateFromString:valueField.text];
                        else
                            self.pickerView.date = [NSDate date];
                    }else
                    {
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:0.5];
                        self.pickerView.frame = CGRectMake(0, 500, pickerView.frame.size.width,pickerView.frame.size.height); // place the pickerView outside the screen
                        [pickerView removeFromSuperview];
                        [UIView commitAnimations];
                        UITextField *textField = (UITextField *)[nextCell.contentView viewWithTag:1001];
                        [textField becomeFirstResponder];
                    }
                }
                else
                {
                    UITableViewCell *nextCell = [_tableView cellForRowAtIndexPath:newIndexPath];
                    if (nextCell == nil) {
                        return;
                    }else{
                        selectedIndexPath = newIndexPath;
                    }
                    [self scrollCell:nextCell];//ScrollCell
                    
                    if ([nextCell.reuseIdentifier isEqualToString:@"date"])
                    {
                        UILabel *valueField = (UILabel*)[nextCell.contentView viewWithTag:1001];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                        [self.view endEditing:YES];
                        toolBar.alpha = 1.0;
                        toolBar.frame = CGRectMake(0, _tableView.frame.size.height-pickerView.frame.size.height-self.toolBar.frame.size.height,self.view.bounds.size.width,35);
                        
                        if(valueField.text != nil)
                            self.pickerView.date = [dateFormatter dateFromString:valueField.text];
                        else
                            self.pickerView.date = [NSDate date];
                        
                        self.pickerView.frame = CGRectMake(0, 500, pickerView.frame.size.width,pickerView.frame.size.height); // place the pickerView outside the screen boundaries
                        [self.pickerView setHidden:NO]; // set it to visible and then animate it to slide up
                        
                        [UIView beginAnimations:nil context:nil];
                        self.pickerView.frame = [self pickerViewFrame];
                        
                        [self.view addSubview:toolBar];
                        [self.view addSubview:pickerView];
                        [UIView commitAnimations];
                    }else
                    {
                        EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:selectedIndexPath.section];
                        DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:selectedIndexPath.row];
                        UITextField *currentTextField = (UITextField *)[cell.contentView viewWithTag:1001];
                        //[(DataObject *)[_detailedData objectAtIndex:0] setObject:currentTextField.text forFieldName:dof.name];
                        [dataSource setObject:currentTextField.text forKey:dof.name];
                        UITextField *newTextField = (UITextField *)[nextCell.contentView viewWithTag:1001];
                        [newTextField becomeFirstResponder];
                    }
                }
            }
            break;
        case kNextSegementItemIndex:
            //if(selectedIndexPath.row < [self effectiveRowIndexWithIndexPath:selectedIndexPath])
            if([self hasNext:selectedIndexPath])
            {
                NSIndexPath *newIndexPath;
                if (selectedIndexPath.row+1 >= [_tableView numberOfRowsInSection:selectedIndexPath.section]) {
                    newIndexPath = [NSIndexPath indexPathForRow:0 inSection:selectedIndexPath.section+1];
                }else{
                    newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row+1 inSection:selectedIndexPath.section];
                }
                
                
                UITableViewCell *nextCell = [_tableView cellForRowAtIndexPath:newIndexPath];
                [self scrollCell:nextCell];//ScrollCell
                if([cell.reuseIdentifier isEqualToString:@"date"])
                {
                    if ([nextCell.reuseIdentifier isEqualToString:@"date"])
                    {
                        UILabel *valueField = (UILabel*)[nextCell.contentView viewWithTag:1001];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                        if(valueField.text != nil)
                            self.pickerView.date = [dateFormatter dateFromString:valueField.text];
                        else
                            self.pickerView.date = [NSDate date];
                    }else
                    {
                        UITextField *textField = (UITextField *)[nextCell.contentView viewWithTag:1001];
                        [textField becomeFirstResponder];
                    }
                }
                else
                {
                    //UITableViewCell *nextCell = [_tableView cellForRowAtIndexPath:newIndexPath];
                    if ([nextCell.reuseIdentifier isEqualToString:@"date"])
                    {
                        UILabel *valueField = (UILabel*)[nextCell.contentView viewWithTag:1001];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                        [self.view endEditing:YES];//dismiss if there is a keypad
                        self.toolBar.alpha = 1.0;
                        //self.toolBar.frame = CGRectMake(0, _tableView.frame.size.height-pickerView.frame.size.height-self.toolBar.frame.size.height,self.view.bounds.size.width,35);
                        toolBar.frame = [self toolBarFrame];
                        
                        
                        if(valueField.text != nil)
                            self.pickerView.date = [dateFormatter dateFromString:valueField.text];
                        else
                            self.pickerView.date = [NSDate date];
                        
                        self.pickerView.frame = CGRectMake(0, 500, pickerView.frame.size.width,pickerView.frame.size.height); // place the pickerView outside the screen boundaries
                        [self.pickerView setHidden:NO]; // set it to visible and then animate it to slide up
                        [UIView beginAnimations:nil context:nil];
                        self.pickerView.frame = [self pickerViewFrame];  
                        [self.view addSubview:toolBar];
                        [self.view addSubview:pickerView];
                        [UIView commitAnimations];
                    }else
                    {
                        EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:selectedIndexPath.section];
                        DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:selectedIndexPath.row];
                        UITextField *currentTextField = (UITextField *)[cell.contentView viewWithTag:1001];
                        [dataSource setObject:currentTextField.text forKey:dof.name];
                        //[(DataObject *)[_detailedData objectAtIndex:0] setObject:currentTextField.text forFieldName:dof.name];
                        UITextField *newTextField = (UITextField *)[nextCell.contentView viewWithTag:1001];
                        [newTextField becomeFirstResponder];
                    }
                }
                selectedIndexPath = newIndexPath;
            }
            break;
        default:
            break;
    }
}

-(void)scrollCell:(UITableViewCell*)cell
{
    selectedIndexPath = [_tableView indexPathForCell:cell];
    NSInteger rowIndex = [self effectiveRowIndexWithIndexPath:selectedIndexPath]+selectedIndexPath.row;//[selectedIndexPath row];
    NSLog(@"ROW INDEX %i",rowIndex);
    NSInteger rowHeight = (rowIndex + 1)*cell.frame.size.height;
    NSLog(@"Row Height is %i",rowHeight);
    NSLog(@"Tbaleview height is %f",_tableView.frame.size.height);
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        if(rowHeight < 106){
            _tableView.contentInset =  UIEdgeInsetsZero;
        }
        else{
            _tableView.contentInset =  UIEdgeInsetsMake(0.0, 0.0, rowHeight-106.0, 0.0);
            [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES ];
        }
    }
    else{
        if(rowHeight < (_tableView.frame.size.height-216-57)){
            _tableView.contentInset =  UIEdgeInsetsZero;
        }
        else{
            _tableView.contentInset =  UIEdgeInsetsMake(0.0, 0.0, rowHeight-(_tableView.frame.size.height-200), 0.0);
            [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES ];
        }
    }
}

-(void)didTextChanged:(id)sender
{
    UITextField *textField = (UITextField*)sender;
    EditViewSectionItem *evSectionItem = [editableDataObjectFields objectAtIndex:selectedIndexPath.section];
    DataObjectField *dof  = [evSectionItem.rowItems objectAtIndex:selectedIndexPath.row];
    [dataSource setObject:textField.text forKey:dof.name];
}

-(NSInteger)effectiveRowIndexWithIndexPath:(NSIndexPath *)indexpath
{
    int i,rowsCount=0;
    for (i=0; i<indexpath.section; i++) {
        rowsCount += [_tableView numberOfRowsInSection:i]; 
    }
    return rowsCount;
}
-(NSInteger)totalRowsCount
{
    NSInteger rowsCount=0;
    for (NSInteger i=0 ; i<[_tableView numberOfSections]; i++) {
        rowsCount += [_tableView numberOfRowsInSection:i];
    }
    return rowsCount;
}
-(BOOL)hasNext:(NSIndexPath *)indexPath
{
    NSInteger currentRowIndex = [self effectiveRowIndexWithIndexPath:indexPath]+indexPath.row;
    NSInteger totalRowCount = [self totalRowsCount];
    if(currentRowIndex == totalRowCount-1){
        return NO;
    }else{
        return YES;
    }
}
-(BOOL)hasPrevious:(NSIndexPath *)indexPath
{
    NSInteger currentRowIndex = [self effectiveRowIndexWithIndexPath:indexPath]+indexPath.row;
    if (currentRowIndex > 0) {
        return YES;
    }else{
        return NO;
    }
}
@end
