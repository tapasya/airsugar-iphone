var target = UIATarget.localTarget();
var appWindow = target.frontMostApp().mainWindow();


// Funciton for delay

function delay(n)
{
	UIATarget.localTarget().delay(n);
}

// Function for Log element tree

function logTree()
{
	appWindow.logElementTree();
}


function messageBox()
{
	UIATarget.onAlert = function onAlert(alert) {
var title = alert.name();
//UIALogger.logWarning("Alert with title '" + title + "' encountered.");
		delay(1);
if (title == "Invalid Login"){
	delay(2);
if(alert.staticTexts()["Login attempt failed please check the username and password"].isValid())
	{
		alert.buttons()["OK"].tap();
		UIALogger.logPass("Error message box is displayed");
	}
	else
	{
		UIALogger.logFail("Error message box is not displayed");
	}
	
	return true;
}
		else
		{
			UIALogger.logFail("Unable to find the ERROR message box");
			//	alert.buttons()["OK"].tap();
		}
// return false to use the default handler
	return false;
}
}














delay(6);


if(appWindow.navigationBar().staticTexts()["Modules"].isValid())
{
	
	// Modules screen
	var modulesNavigationbarButton = appWindow.navigationBar().buttons()["Settings"];
	
	UIALogger.logStart("Check for the settings button in the modules screen");
	if(modulesNavigationbarButton.isValid())
	{
		UIALogger.logPass("Settins button exists");
	}
	else
	{
		UIALogger.logFail("Settings button does not exists");
	}
	
	UIALogger.logStart("click on settings button and check if user is able to navigate to the settings screen");
	modulesNavigationbarButton.tap();
	delay(1);
	if(appWindow.navigationBar().staticTexts()["Settings"].isValid())
	{
		UIALogger.logPass("User has navigated to the settings page");
	}
	else
	{
		UIALogger.logFail("USer is unable to navigate to settings page");
	}
	
	// Settings screen
	var settingsNavigationbar = appWindow.navigationBar();
	var tableviews = appWindow.tableViews()[0];
	
	
	UIALogger.logStart("Check for the Modules button and the save button in the settings screen");
	if(settingsNavigationbar.buttons()["Modules"].isValid && settingsNavigationbar.buttons()["Save"].isValid())
	{
		UIALogger.logPass("User is able to see the two buttons SAVE and MODULES");
	}
	else
	{
		UIALogger.logFail("User is unable to see the two buttons SAVE and MODULES");
	}
	
	
	UIALogger.logStart("Check is SAVE button is enabled or not");
	if(!appWindow.navigationBar().buttons()["Save"].isEnabled())
	{
		UIALogger.logPass("Save button is not enabled");
	}
	else
	{
		UIALogger.logFail("Save button is enabled");
	}
	
	
	UIALogger.logStart("Change the User Name and check if Save button is enabled not");
	tableviews.cells()["Username"].textFields()[0].setValue("williams");
	tableviews.cells()["Password"].secureTextFields()[0].setValue("williams");
	if(appWindow.navigationBar().buttons()["Save"].isEnabled())
	{
		UIALogger.logPass("Save button is enabled");
	}
	else
	{
		UIALogger.logFail("Save button is not enabled");
	}
	
	
	UIALogger.logStart("Now Click on Save button and check for the Error message box");
	appWindow.navigationBar().buttons()["Save"].tap();
	messageBox();
	
	logTree();
	delay(2);
	
	UIALogger.logStart("Click on Sync Settings button");
	appWindow.tableViews()[0].cells()["Sync Settings"].tap();
	if(appWindow.navigationBar().staticTexts()["Sync Settings"].isValid())
	{
		UIALogger.logPass("User is in sync settings screen");
	}
	else
	{
		UIALogger.logFail("User is not in Sync settings screen");
	}
	delay(2);
	
	UIALogger.logStart("In Sync settings screen check for the Erase all button");
	if(appWindow.tableViews()[0].cells()["Erase All"].isValid())
	{
		UIALogger.logPass("Erase All button exists");
	}
	else
	{
		UIALogger.logFail("Erase all buttons does not exists");
	}
	delay(2);
	
	UIALogger.logStart("In Sync settings screen check for the sync now button");
	if(appWindow.tableViews()[0].cells()["Sync Now"].isValid())
	{
		UIALogger.logPass("Sync Now button exists");
	}
	else
	{
		UIALogger.logFail("Sync Now button does not exists");
	}
	delay(2);
	
	UIALogger.logStart("Clcik on sync settings back button and check if user is able to navigate to the settings screen");
	appWindow.navigationBar().buttons()["Settings"].tap();
	if(appWindow.navigationBar().staticTexts()["Settings"].isValid())
	{
		UIALogger.logPass("User is in settings screen");
	}
	else
	{
		UIALogger.logFail("User is not in settings screen");
	}
	delay(1);
	//target.frontMostApp().keyboard().keys()["Done"].tap();
	//logTree();
	
	
	UIALogger.logStart("Click on LogOut button and check if user has navigated to the login screen");
	appWindow.tableViews()[0].cells()["Logout"].tap();
	
	UIATarget.onAlert = function onAlert(alert) {
	var title = alert.name();
	UIALogger.logWarning("Alert with title '" + title + "' encountered.");
	if (title == "Confirm") {
	alert.buttons()["OK"].tap();
	return true; //alert handled, so bypass the default handler
	}
	// return false to use the default handler
	return false;
	}
	
	
	
	
	delay(6);
	if(appWindow.scrollViews()[0].buttons()["Login"].isValid())
	{
		UIALogger.logPass("User has navigated to the login screen");
	}
	else
	{
		UIALogger.logFail("User is unable to navigate to the login screen");
	}
	
	
	
	




	



}
else
{
	UIALogger.logFail("User is not in Modules screen");
}

