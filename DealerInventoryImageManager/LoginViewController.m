//
//  LoginViewController.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "LoginViewController.h"
#import "InventoryViewController.h"
#import "Reachability.h"
#import "DealerModel.h"
#import "LotInfo.h"
#import "ConnectUpSettings.h"

//#define multiLotInfoURL @"https://www.claytonUpdateCenter.com/cfide/remoteInvoke.cfc?method=processGetJSONArray&obj=retail&MethodToInvoke=prcIndependentSingleOwnerMultiDealersRead&key=Ly9VUThFNSJBU0VHN14rWy5LNEUuCg%3D%3D&UserID="

#define multiLotInfoURL @"https://www.claytonupdatecenter.com/cmhapi/connect.cfc?"

@interface Displaying_Alerts_with_UIAlertViewViewController : UIViewController <UIAlertViewDelegate>
@end


@interface LoginViewController ()
{
    Reachability *internetReachable;
}
@end





@implementation LoginViewController


-(id) init{
    
    
    // If the plist file doesn't exist, copy it to a place where it can be worked with.
    // Setup settings to contain the data.
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"ConnectUpSettings.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // use to delete and reset app.
    //[fileManager removeItemAtPath:docfilePath error:NULL];
    
    if (![fileManager fileExistsAtPath:docfilePath]){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ConnectUpSettings" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:docfilePath error:nil];
    }
    self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:docfilePath];
    
    
    return self;
}


#pragma mark - View lifecycle

/* ****************************************************
 Handle misc Method Communications
 ***************************************************** */

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"return button hit");
    [self completeLogin];
    return YES;
}


-(NSString *) yesButtonTitle{
    return @"I'm Connected";
}





/* ****************************************************
 Alert View Overide
 ***************************************************** */
- (void)      alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:[self yesButtonTitle]]){
        // Re-run the check
        // Are we online?
        [self checkOnlineConnection];
    }
    
}


/* ****************************************************
 Check to see if the phone is online
 ***************************************************** */
- (void) checkOnlineConnection {


    internetReachable = [Reachability reachabilityForInternetConnection];
    
    NSLog(@"%@", internetReachable.currentReachabilityFlags);
    NSLog(@"%@", internetReachable.currentReachabilityString);
    NSLog(@"BOOL = %@\n", (internetReachable.currentReachabilityStatus ? @"YES" : @"NO"));

    if (internetReachable.currentReachabilityStatus) {
        _isConnected = TRUE;
    } else {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"No Connection"
                                      message:@"Please connect to the internet."
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:[self yesButtonTitle], nil];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
            [alertView setTransform:transform];
            
            [alertView show];
        });
    }
    
    [internetReachable startNotifier];
    
}

/* ****************************************************
 Check that user is online
 ***************************************************** */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    
    // Get settings.
    ConnectUpSettings *connectUpSettings = [[ConnectUpSettings alloc] init];
    NSMutableDictionary *settings = [connectUpSettings getSettings];
    
    
    // if the user hasn't seen this view, show it
    /*
    if ([[settings valueForKey:@"legalAgreed"] isEqualToString:@"0"]){
        
        // Show the upload view.
        [UIView beginAnimations:@"fade" context:nil];
        [UIView setAnimationDuration:0.0];
        self.legalView.alpha = 1.0;
        [UIView commitAnimations];

    }
     */
    
    
    
    
    id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
    // Are we online?
    [self checkOnlineConnection];
	
	if (_currentDealer) {
		_userName.text = _currentDealer.userName;
	}
	
	_password.delegate = self;
    
    // manage Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}



/* ****************************************************
 Remove Keyboard From View
 ***************************************************** */
- (IBAction)offKeyboardButton:(id)sender {
    [sender resignFirstResponder];
    [self.view endEditing:YES];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    loginScrollView.contentInset = contentInsets;
    loginScrollView.scrollIndicatorInsets = contentInsets;
}


- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
    
    int keyboardHeight;
    
    // Adjust scroll view distance based on the screen size.
    if([UIScreen mainScreen].bounds.size.height == 568){
        keyboardHeight = keyboardSize.height-25;
    } else{
        keyboardHeight = keyboardSize.height-40;
    }
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    loginScrollView.contentInset = contentInsets;
    loginScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardHeight;
    
    
    //if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
    CGPoint scrollPoint = CGPointMake(0.0, (keyboardHeight));
    [loginScrollView setContentOffset:scrollPoint animated:YES];
    //}
    
    
}



/* ****************************************************
 User Login
 ***************************************************** */
- (IBAction)logInSubmit:(id)sender {
    [sender resignFirstResponder];
    [self.view endEditing:YES];
    [self completeLogin];
}


- (void) completeLogin {
    
    // If either of the fields is empty, throw an erorr
    if ( _password.text.length == 0 || _userName.text.length == 0 ){
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Login Error"
                                  message:@"Please Enter Your User Name and Password."
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        
        // if the fields are filled, bounce it against the data.
    } else {
        
        
        [self clearEntity:@"Dealer" withFetchRequest:_fetchRequest];
        
        // Register user
        //
        DealerModel *dealerModel = [[DealerModel alloc] init];
        _isDealerSuccess = [dealerModel registerDealerWithUsername:_userName.text WithPassword:_password.text ];
		[dealerModel getDealerNumber];
		_dealerNumber = dealerModel.dealerNumber;
        
        // Was the dealer login successful?
        //
        if (_isDealerSuccess == YES){

            [self getLotInfo:_dealerNumber];
			if ([_lotArray count] > 1) {
				[self performSegueWithIdentifier:@"segueToDealerSelectFromLogin" sender:self];
			}else{
				[self performSegueWithIdentifier:@"segueToInventoryViewController" sender:self];
			}
        }
		else {
            // Show an error if login was not correct.
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Login Error"
                                      message:@"The Name or Password were Incorrect. Please try again."
                                      delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Ok", nil];
            [alertView show];
        }
        
        
        
    }
    
}


- (void)getLotInfo:(NSString *)dealerNumber
{
	[self init];
    [self loadLotInfo];
	
	if (_isConnected == 1 && [_lotArray count] > 0) {
		[self clearEntity:@"LotInfo" withFetchRequest:_fetchRequest];
	}

    NSLog(@"%@", self.settings);
    
    NSString *function = @"PrcIndependentSingleOwnerMultiDealersRead";
    NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
    NSString *urlString = [NSString stringWithFormat:@"%@method=gateway&function=%@&accesstoken=%@&userid=%@",
                                
                                multiLotInfoURL,
                                function,
                                accessToken,
                                
                                dealerNumber
                                ];
	NSURL *lotInfoURL = [NSURL URLWithString:urlString];
	NSData *data = [NSData dataWithContentsOfURL:lotInfoURL];
	
	// Sticks all of the jSON data inside of a dictionary
    _jSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	
	// Creates a dictionary that goes inside the first data object eg. {data:[
	_dataDictionary = [_jSON objectForKey:@"data"];
	
	// Check for other dictionaries inside of the dataDictionary
	for (NSDictionary *lotDictionary in _dataDictionary) {
		
		LotInfo *lotInfo = [NSEntityDescription insertNewObjectForEntityForName:@"LotInfo" inManagedObjectContext:[self managedObjectContext]];
		
		lotInfo.address = NSLocalizedString([lotDictionary objectForKey:@"address1"], nil);
		lotInfo.city = NSLocalizedString([lotDictionary objectForKey:@"city"], nil);
		lotInfo.dealerNumber = [NSString stringWithFormat:@"%@", [lotDictionary objectForKey:@"dealernumber"]];
		lotInfo.name = NSLocalizedString([lotDictionary objectForKey:@"name"], nil);
		lotInfo.state = NSLocalizedString([lotDictionary objectForKey:@"stateprovince"], nil);
		lotInfo.phone = [NSString stringWithFormat:@"%lu", (unsigned long)[[lotDictionary objectForKey:@"telephonenumber"] unsignedIntegerValue]];
	}
	[self loadLotInfo];
	[_managedObjectContext save:nil];
}

- (void)loadLotInfo
{
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"LotInfo" inManagedObjectContext:[self managedObjectContext]];
	
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	_lotArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
}

- (void)clearEntity:(NSString *)entityName withFetchRequest:(NSFetchRequest *)fetchRequest
{
	fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
	[fetchRequest setEntity:_entity];
	NSError *error = nil;
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObjectContext *dealer in objects) {
		[[self managedObjectContext] deleteObject:dealer];
	}
	
	NSError *saveError = nil;
	if (![[self managedObjectContext] save:&saveError]) {
		NSLog(@"An error has occurred: %@", saveError);
	}
}

- (void)loadDealer
{
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"Dealer" inManagedObjectContext:[self managedObjectContext]];
	
	[_fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	
	NSArray *dealerArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
	
	_currentDealer = [dealerArray objectAtIndex:0];
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
	if (_isDealerSuccess) {
		return YES;
	}
	else{
		return NO;
	}
}





/* ****************************************************
 Prep Segue to Next View
 ***************************************************** */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"segueToInventoryViewController"]) {
        
        // Load User Data to memory
        
    }
}

- (IBAction)endTyping:(id)sender {
    [sender resignFirstResponder];
	//[self logInSubmit:(id)sender];
    [self.view endEditing:YES];
    
}

- (IBAction)IAgreeButton:(id)sender {
    
    // Remove the view on click.
    [UIView beginAnimations:@"fade" context:nil];
    [UIView setAnimationDuration:0.5];
    self.legalView.alpha = 0.0;
    [UIView commitAnimations];
    
    
    // load the pList data
    ConnectUpSettings *connectUpSettings = [[ConnectUpSettings alloc] init];
    NSMutableDictionary *settings = [connectUpSettings getSettings];
    
    
    // Change the data that was loaded
    [settings setObject:@"1" forKey:@"legalAgreed"];
    
    // write data
    [connectUpSettings writeToSettings:settings];
    
    
}
@end
