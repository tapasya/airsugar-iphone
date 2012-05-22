var target = UIATarget.localTarget();
var appWindow = target.frontMostApp().mainWindow();

UIATarget.localTarget().delay(5);

// Function for checking if the module icons exists or not

function moduleIcon(n)
{
	if(appWindow.scrollViews()[0].images()[n].isValid())
{
	UIALogger.logPass("User is able to see the "+n+" icon in Modules screen");
}
else
{
	UIALogger.logPass("User is unable to see the "+n+" icon in the modules screen");
}
}



UIALogger.logStart("Checking if Opportunities icon exists in the Modules screen");
moduleIcon("Opportunities");

UIALogger.logStart("Checking if Campaigns icon exists in the Modules screen");
moduleIcon("Campaigns")


UIALogger.logStart("Checking if Leads icon exists in the Modules screen");
moduleIcon("Leads");

UIALogger.logStart("Checking if Cases icon exists in the Modules screen");
moduleIcon("Cases");


UIALogger.logStart("Checking if Calls icon exists in the Modules screen");
moduleIcon("Calls");


UIALogger.logStart("Checking if Accounts icon exists in the Modules screen");
moduleIcon("Accounts");


UIALogger.logStart("Checking if Contacts icon exists in the Modules screen");
moduleIcon("Contacts");


UIALogger.logStart("Checking if Meetings icon exists in the Modules screen");
moduleIcon("Meetings");


UIALogger.logStart("Checking if Recent icon exists in the Modules screen");
moduleIcon("itemimage");


//UIALogger.logDebug("Done with checking all icons in the modules screen");
















