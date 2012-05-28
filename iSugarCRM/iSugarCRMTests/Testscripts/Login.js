
var target = UIATarget.localTarget();
var appWindow = target.frontMostApp().mainWindow();

var login = appWindow.scrollViews()[0].buttons()["Login"];
var username = appWindow.scrollViews()[0].textFields()[1];
var password = appWindow.scrollViews()[0].secureTextFields()[0];


// Function for delay

function delay(n)
{
	UIATarget.localTarget().delay(n);
}

// Function Sync setup text in the navigation bar

function syncSetup()
{
	if(appWindow.navigationBar().staticTexts()["Sync Setup"].isValid)
	{
		UIALogger.logPass("User is in Sync set up screen");
	}
	else
	{
		UIALogger.logFail("User is not in Sync set up screen");
	}
}

// function for the Login button

function loginButton()
{
	if(appWindow.scrollViews()[0].buttons()["Login"].isValid())
	{
		appWindow.scrollViews()[0].buttons()["Login"].tap();
		UIALogger.logPass("Login button exists and user has tapped on login button");
	}
	else
	{
		UIALogger.logFail("User is unable to click on Login button");
	}
}

// Function for displaying a message box1

function messageBox()
{
	UIATarget.onAlert = function onAlert(alert) {
var title = alert.name();
//UIALogger.logWarning("Alert with title '" + title + "' encountered.");
		delay(1);
if (title == "Error"){
	delay(2);
if(alert.staticTexts()["Please check your details and relogin"].isValid())
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


// Function for displaying a message box 2

function messageBox2()
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




// Clearing the texts in user name and in password fields

username.setValue("");
password.setValue("");
target.frontMostApp().keyboard().buttons()["return"].tap();
delay(1);

UIALogger.logStart("Check if user is able to login into applicaiton with out entering username and password");
login.tap();
messageBox();
delay(1);

UIALogger.logStart("Check if user is able to login into the applicaiton by entering only user name");
username.setValue("will");
target.frontMostApp().keyboard().buttons()["return"].tap();
login.tap();
messageBox();
delay(1);

UIALogger.logStart("Check if user is able to login into the applicaiton by entering only password");
username.setValue("");
delay(1);
password.setValue("will");
target.frontMostApp().keyboard().buttons()["return"].tap();
login.tap();
messageBox();
delay(1);

UIALogger.logStart("Check if user is able to login into the applicaiton by entering invalid username and invalid password");
username.setValue("williams");
password.setValue("abcdefghijkl");
target.frontMostApp().keyboard().buttons()["return"].tap();
login.tap();
messageBox2();
delay(1);

UIALogger.logStart("Check if user is able to login into the applicaiton by entering valid username and invalid password");
username.setValue("will");
password.setValue("abcdefghijkl");
target.frontMostApp().keyboard().buttons()["return"].tap();
login.tap();
messageBox2();
delay(1);

UIALogger.logStart("Check if user is able to login into the applicaiton by entering invalid username and valid password");
username.setValue("williams");
password.setValue("will");
target.frontMostApp().keyboard().buttons()["return"].tap();
login.tap();
messageBox2();
delay(1);

UIALogger.logStart("Check if user is able to navigate to Sync setup screen by entering valid username and valid password");
username.setValue("will");
password.setValue("will");
target.frontMostApp().keyboard().buttons()["return"].tap();
loginButton();
delay(4);

UIALogger.logStart("Check if user is in Sync setup screen");
if(appWindow.navigationBar().staticTexts()["Sync Setup"].isValid())
{
	UIALogger.logPass("User is in Sync setup page");
}
else
{
	UIALogger.logFail("User is not is sync setup page");
}

