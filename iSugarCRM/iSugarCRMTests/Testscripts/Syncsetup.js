var target = UIATarget.localTarget();
var appWindow = target.frontMostApp().mainWindow();

UIALogger.logStart("Check if user is in Sync setup screen");
if(appWindow.navigationBar().staticTexts()["Sync Setup"].isValid())
{
	UIALogger.logPass("User is in Sync setup page");
}
else
{
	UIALogger.logFail("User is not is sync setup page");
}

UIALogger.logStart("Set start date less than the end date and check if the next button is enabled");

// Setting end date date less than the start date
appWindow.tableViews()[0].cells()[0].tap();
target.frontMostApp().actionSheet().pickers()[0].wheels()[2].selectValue(2008);
target.frontMostApp().actionSheet().toolbar().buttons()[0].tap();
if(appWindow.navigationBar().buttons()["Next"].isEnabled())
{
	UIALogger.logPass("Next button is enabled");
}
else
{
	UIALogger.logFail("Next button is not enabled");
}

UIALogger.logStart("Set both start date and end date and check if the next button is enabled");
appWindow.tableViews()[0].cells()[1].tap();
target.frontMostApp().actionSheet().pickers()[0].wheels()[2].selectValue(2012);
target.frontMostApp().actionSheet().toolbar().buttons()[0].tap();
if(appWindow.navigationBar().buttons()["Next"].isEnabled())
{
	UIALogger.logPass("Next button is not enabled");
}
else
{
	UIALogger.logFail("Next button is enabled");
}

UIALogger.logStart("Check if user is able to click on NEXT button in Sync set up screen");
if(appWindow.navigationBar().buttons()["Next"].isValid())
{
	appWindow.navigationBar().buttons()["Next"].tap();
	UIALogger.logPass("User has clicked on NEXT button");
}
else
{
	UIALogger.logFail("User has not clicked on NEXT button");
}


UIALogger.logStart("Check if user is able to navigate to Module screen,after clicking on NEXT button in sync setup screen");
appWindow.logElementTree();
if(appWindow.navigationBar().staticTexts()["Modules"].isValid())
{
	UIALogger.logPass("User has Navigated to the Modules screen");
}
else
{
	UIALogger.logFail("User is unable to navigate to the Modules screen");
}
