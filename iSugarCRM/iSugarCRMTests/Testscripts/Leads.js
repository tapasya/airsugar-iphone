var target = UIATarget.localTarget();
var appWindow = target.frontMostApp().mainWindow();

var addbutton = appWindow.navigationBar().segmentedControls()[0].buttons()[2];

function delay(n)
{
	UIATarget.localTarget().delay(n);
}

// function for log tree
function logTree()
{
	appWindow.logElementTree();
}

// function for disable SAVE button
function saveButtonDisable()
{
	if(!appWindow.navigationBar().buttons()["Save"].isEnabled())
	{
		UIALogger.logPass("Save button is not enabled");
	}
	else
	{
		UIALogger.logFail("Save button is enabled");
	}
	
}

// function for Enable SAVE button
function saveButtonEnable()
{
	if(appWindow.navigationBar().buttons()["Save"].isEnabled())
	{
		UIALogger.logPass("Save button is not enabled");
	}
	else
	{
		UIALogger.logFail("Save button is enabled");
	}
	
}

// function for sync completed message box

function syncCompletedMessageBox()
{
	UIATarget.onAlert = function onAlert(alert) {
	var title = alert.name();
	//UIALogger.logWarning("Alert with title '" + title + "' encountered.");
	delay(3);
	if(alert.staticTexts()["Sync Completed"].isValid())
	{
		alert.buttons()["Ok"].tap();
		delay(1);
		UIALogger.logPass("Sync Completed message box is displayed");
	}
	else
	{
		UIALogger.logFail("Sync Completed message box is not displayed");
	}
	
	return true;
}
}

// CODE STARTS FROM HERE

delay(8);
UIALogger.logStart("Click on Leads icon and check if user is able to navigate to the campaings page");
// Clicking on Leads icon by co-ordinates
UIATarget.localTarget().tap({x:236, y:88});
if(appWindow.navigationBar().staticTexts()["Leads"].isValid())
{
	UIALogger.logPass("User has navigated to the Leads page");
}
else
{
	UIALogger.logFail("User is unable to navigate to the Leads page");
}


UIALogger.logStart("Check if user is able to see the button Modules in the navigation bar");
if(appWindow.navigationBar().buttons()["Modules"].isValid())
{
	UIALogger.logPass("Module button exists in the Leads screen");
}
else
{
	UIALogger.logFail("Module button does not exists in the Leads screen");
}

delay(1);

UIALogger.logStart("Check if user is able to see the buttons Settings , Sync , Add in the navigation bar");
if(appWindow.navigationBar().segmentedControls()[0].buttons()["settings"].isValid() && appWindow.navigationBar().segmentedControls()[0].buttons()["sync"].isValid() && appWindow.navigationBar().segmentedControls()[0].buttons()["manage"].isValid())
{
	UIALogger.logPass("Settings,sync,add button exits");
}
else
{
	UIALogger.logFail("Settings,sync,add button does not exists");
}

UIALogger.logStart("Click on Add button and check if Action sheet is enabled or not");
appWindow.navigationBar().segmentedControls()[0].buttons()["manage"].tap();
delay(1);
if(target.frontMostApp().actionSheet().isEnabled())
{
	UIALogger.logPass("Action sheet is enabled");
}
else
{
	UIALogger.logFail("Action sheet is not enabled");
}

// variables for the action sheet
var actionsheet = target.frontMostApp().actionSheet();

UIALogger.logStart("Check if user is able to see the 3 buttons in the action sheet");
if(actionsheet.buttons()["Add"].isValid && actionsheet.buttons()["Delete"].isValid() && actionsheet.buttons()["Cancel"].isValid())
{
	UIALogger.logPass("Three buttons exists in the action sheet");
}
else
{
	UIALogger.logFail("Three buttons does not exists in the action sheet");
}

UIALogger.logStart("Click on Add button in the action sheet and check if it is navigating to Add Record screen");
actionsheet.buttons()["Add"].tap();
delay(1);
if(appWindow.navigationBar().staticTexts()["Add Record"].isValid())
{
	UIALogger.logPass("User has navigated to the Add Record screen");
}
else
{
	UIALogger.logFail("User is unable to navigate to the Add Record screen");
}

UIALogger.logStart("In the Add record screen , check if SAVE button is disabled or not");
saveButtonDisable();

UIALogger.logStart("Check for the Last name field in the Add record screen , if it exists then click on Last Name field");
if(appWindow.tableViews()[0].cells()["Last Name"].staticTexts()["Last Name"].isValid())
{
	appWindow.tableViews()[0].cells()["Last Name"].tap();
	UIALogger.logPass("Last Name field exists and user has clicked on that");
}
else
{
	UIALogger.logFail("Last Name field does not exists");
}

UIALogger.logStart("Entering the string in the last name field");
UIATarget.localTarget().frontMostApp().keyboard().typeString("I");
UIATarget.localTarget().frontMostApp().keyboard().typeString("C");
UIATarget.localTarget().frontMostApp().keyboard().typeString("R");
UIATarget.localTarget().frontMostApp().keyboard().typeString("M");
delay(1);
if(appWindow.tableViews()[0].cells()[0].textFields()[0].value()=="ICRM")
{
	appWindow.toolbar().buttons()["Done"].tap();
	UIALogger.logPass("ICRM got entered");
}
else
{
	UIALogger.logFail("Unable to see the text in the search bar");
}
delay(1);

UIALogger.logStart("Check if Save button is enabled or not");
saveButtonEnable();

UIALogger.logStart("In the Add record screen ,Click on SAVE button and check for the SYNC COMPLETED message box");
appWindow.navigationBar().buttons()["Save"].tap();
syncCompletedMessageBox();
delay(2);

UIALogger.logStart("Check if user is back to the LEADS screen");
if(appWindow.navigationBar().staticTexts()["Leads"].isValid())
{
	UIALogger.logPass("User is Back to Leads page");
}
else
{
	UIALogger.logFail("User is unable to navigate to the Leads page");
}

UIALogger.logStart("Tap on the search bar and enter ICRM and check if it is displaying the result properly");
appWindow.searchBars()[0].tap();
delay(1);
UIATarget.localTarget().frontMostApp().keyboard().typeString("I");
UIATarget.localTarget().frontMostApp().keyboard().typeString("C");
UIATarget.localTarget().frontMostApp().keyboard().typeString("R");
UIATarget.localTarget().frontMostApp().keyboard().typeString("M");
delay(1);
logTree();
if(appWindow.tableViews()[0].cells()[0].staticTexts()["ICRM, Title: NA"].isValid())
{
	UIALogger.logPass("Result is shown properly");
}
else
{
	UIALogger.logFail("Result is not shown properly");
}

UIALogger.logStart("Tap on the result and check if it page is getting navigated to the detail view of the Lead");
appWindow.tableViews()["Empty list"].cells()[0].tap();
delay(1);
if(appWindow.navigationBar().staticTexts()["ICRM"].isValid())
{
	UIALogger.logPass("User has navigated to detailed page of the LEAD");
}
else
{
	UIALogger.logFail("User is unable to navigate to detailed page of the LEAD");
}

UIALogger.logStart("Now Go back to Modules screen");
appWindow.navigationBar().leftButton().tap();
delay(1);
appWindow.navigationBar().buttons()["Modules"].tap();
delay(1);
if(appWindow.navigationBar().staticTexts()["Modules"].isValid())
{
	UIALogger.logPass("User has Navigated to the Modules screen");
}
else
{
	UIALogger.logFail("User is unable to navigate to the Modules screen");
}











