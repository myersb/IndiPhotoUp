//
//  ImageDetailsViewController.m
//  DealerInventoryImageManager
//
//  Created by Chris Cantley on 11/1/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "ImageDetailsViewController.h"
#import "ImageTagsModel.h"
#import "ImageTags.h"
#import "ImageTypesModel.h"
#import "ImageTypes.h"
#import "InventoryImageModel.h"
#import "Reachability.h"

@interface ImageDetailsViewController ()
{
    Reachability *internetReachable;
}

@end

@implementation ImageDetailsViewController

@synthesize activeTextField, imageTagRow, pickerViewContainer, activityIndicatorBackground;


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ImageDetailesViewController : viewDidLoad");
    
    
    // Do any additional setup after loading the view.
    // Draw the activity view background
    activityIndicatorBackground.layer.cornerRadius = 10.0;
    activityIndicatorBackground.layer.borderColor = [[UIColor grayColor] CGColor];
    activityIndicatorBackground.layer.borderWidth = 1;
	
    // *** Load data into the Pickers ***
    ImageTagsModel *imageTagsModel  = [[ImageTagsModel alloc] init];
    NSArray *getImageTags = [imageTagsModel readImageTags];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagDescription" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *sortedArray = [getImageTags sortedArrayUsingDescriptors:sortDescriptors];
    imageTagArray = sortedArray;
    
    // Load data for Image Type
    ImageTypesModel *imageTypesModel = [[ImageTypesModel alloc] init];
    NSArray *getImageType = [imageTypesModel readImageTypes];
    imageTypeArray = getImageType;
    
    // *** Set Values in display ***
    
    NSLog(@"%@", _selectedSerialNumber);
    
    if (!_currentInventoryModel.serialNumber) {
		_homeImage.image = _selectedImage;
		NSMutableArray *barButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
		
		// This is how you remove the button from the toolbar and animate it
		[barButtonItems removeObject:_deleteButton];
		[self.navigationItem setRightBarButtonItems:barButtonItems animated:YES];
	}
	else{
		
        // Get and set the image
        NSString *ImageURL =  _currentInventoryImage.sourceURL;
        NSString *imageUrlSized = [ImageURL stringByAppendingString:@"?width=240&height=160"];
        
    
        // Do this as its own process so that the user isn't held up.
        // Activate the Activity indicator on a seperate thread.
        [NSThread detachNewThreadSelector:@selector(threadStartAnimating) toTarget:self withObject:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlSized]];
            
            _homeImage.image = [UIImage imageWithData:imageData];
            
            [NSThread detachNewThreadSelector:@selector(threadStopAnimating) toTarget:self withObject:nil];
        });
    }
    
    // Put the values into the fields
    [_serialNumberLabel setText:[_currentInventoryModel serialNumber]];
    [_homeDescriptionLabel setText:[_currentInventoryModel homeDesc]];
    [_featuresField setText:[_currentInventoryImage imageCaption]];
   
    // manage Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Check to see if there is a feature assocaited with image.  If not, then select one that matches the Group
    NSString *getTagIdForImage;
    
    // Here there is no Tag, so use the Type to find the default tag.
    if ([_currentInventoryImage.imageTagId isEqualToString:@"0"])
    {
        for (ImageTypes *getType in imageTypeArray)
        {
            if ([getType.typeId isEqualToString:_currentInventoryImage.group])
            {
                getTagIdForImage = getType.tagId;
                break;
            }
        }
    }
    // Here, there is a tag so default the picker to the tag.
    else
    {
        getTagIdForImage = _currentInventoryImage.imageTagId;
    }
    
    // Loop over the tagArray, and where there is a match make that the default.
    // Each row starts at 0, so set to 0 first and increment
    int currentRow = 0;
    for (ImageTags *getImage in imageTagArray )
    {
        if ([getImage.tagId isEqualToString:getTagIdForImage])
        {
            [self.imageTag selectRow:currentRow inComponent:0 animated:NO];
            imageTagObjectSelected = getImage;
            
            _imageTypeField.text = [[imageTagArray objectAtIndex:currentRow] tagDescription] ;
            
            break;
        }
        
        // Increment
        currentRow++;
        
    }
}


/* --------------------------------------------------------------- */
#pragma mark Lifecycle Management
/* --------------------------------------------------------------- */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier]isEqualToString:@"segueToHomeDetailsFromImageDetails"]) {
		
		HomeDetailsViewController *homeDetails = [segue destinationViewController];
        homeDetails.selectedSerialNumber = _selectedSerialNumber;
		homeDetails.imageWasSaved = TRUE;

	}
}

-(void)showView{
    
    //[UIView beginAnimations: @"Fade Out" context:nil];
    //[UIView setAnimationDelay:0];
    //[UIView setAnimationDuration:.5];
    //show your view with Fade animation lets say myView
    [activityIndicatorBackground setHidden:FALSE];
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideView) userInfo:nil repeats:YES];
    //[UIView commitAnimations];
}

-(void)hideView{
    //[UIView beginAnimations: @"Fade In" context:nil];
    //[UIView setAnimationDelay:0];
    //[UIView setAnimationDuration:.5];
    //hide your view with Fad animation
    [activityIndicatorBackground setHidden:TRUE];
    //[UIView commitAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // This will hide the view setting the X, Y, Width, height
    // You can get these base numbers from the possition of the view.
    // setting "Y" to 800 will put the view off the screen.
    self.pickerViewContainer.frame = CGRectMake(0, 800, 320, 226);
}

/* --------------------------------------------------------------- */
#pragma mark Keyboard management
/* --------------------------------------------------------------- */
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
    
    int keyboardHeight;
    
    // Adjust scroll view distance based on the screen size.
    if([UIScreen mainScreen].bounds.size.height == 568){
        keyboardHeight = keyboardSize.height+20;
    } else{
        keyboardHeight = keyboardSize.height-55;
    }

    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardHeight;

    
    //if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeTextField.frame.origin.y - (keyboardHeight));
        [theScrollView setContentOffset:scrollPoint animated:YES];
    //}
    
    // The picker comes up behind the keyboard.  This needs to dismiss this view when the keyboard goes away.
    self.pickerViewContainer.frame = CGRectMake(0, 800, 320, 226);
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
}

// Set activeTextField to the current active textfield
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

// Set activeTextField to nil
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

// Dismiss the keyboard
- (IBAction)dismissKeyboard:(id)sender
{
    // unhide the save button
    self.saveButton.hidden = FALSE;
    
    [self.activeTextField resignFirstResponder];

}

/* --------------------------------------------------------------- */
#pragma mark - Drawing Methods
#pragma mark Fetches data and fills objects with image infromation.
/* --------------------------------------------------------------- */

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return imageTagArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    // Return value that will be displayed
    ImageTags *imageTagData = [imageTagArray objectAtIndex:row];
    return imageTagData.tagDescription;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    
    // Set object picked to a higher varialbe to be used later.
    imageTagObjectSelected = [imageTagArray objectAtIndex:row] ;
    
    // when selected in the picker put tag description into the target text field.
    [_imageTypeField setText:[imageTagObjectSelected tagDescription] ];

    
}

- (void) threadStopAnimating {
    [self.activityIndicatorImage stopAnimating];
    [self hideView];
}
- (void) threadStartAnimating {
    [self.activityIndicatorImage startAnimating];
    [self showView];
}

/* --------------------------------------------------------------- */
#pragma mark - Actions methods
/* --------------------------------------------------------------- */

- (IBAction)deleteButton:(id)sender {
    
    NSLog(@"ImageDetailesViewController : deleteButton");
	UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure that you want to delete this image? This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[deleteAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		InventoryImageModel *deleteImage = [[InventoryImageModel alloc] init];
		[deleteImage deleteImageDataByImageId:_currentInventoryImage.imagesId
					  andByInventoryPackageId:_currentInventoryImage.inventoryPackageID];
		
		// Go back to the previous page.
		[self performSegueWithIdentifier:@"segueToHomeDetailsFromImageDetails" sender:self];
		
	}
}

- (IBAction)saveButton:(id)sender{
    NSLog(@"ImageDetailesViewController : saveButton");
    
    // Take data and update core data
    _returnVal = 0;
    
    // push data and image to recieving service
    //
    // This is a New image
    if (!_currentInventoryModel.serialNumber)
    {
        // If this is a new image versus an edit, then _homeImage.image has already been filled.  Execute the uploadImage method.
        
        
        // Check that TypeId has been selected.
        if (imageTagObjectSelected.typeId != nil )
        {
            
            // Check to see if the use is online
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus == NotReachable) {
                _returnVal = 1;
            }
            
            if (_returnVal == 0)
            {
                // Activate the Activity indicator on a seperate thread.
                [NSThread detachNewThreadSelector:@selector(showView) toTarget:self withObject:nil];
                
                // Run the long process on the main thread.
                [self uploadImage];

                id delegate = [[UIApplication sharedApplication] delegate];
                self.managedObjectContext = [delegate managedObjectContext];
                
                _fetchRequest = [[NSFetchRequest alloc]init];
                _entity = [NSEntityDescription entityForName:@"InventoryHome" inManagedObjectContext:[self managedObjectContext]];
                _predicate = [NSPredicate predicateWithFormat:@"serialNumber == %@", _selectedSerialNumber];
                
                [_fetchRequest setEntity:_entity];
                [_fetchRequest setPredicate:_predicate];
                
                NSError *error = nil;
                
                _modelArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
                
                InventoryImageModel *saveInsert = [[InventoryImageModel alloc] init];
                [saveInsert insertImageDataByInventoryPackageId:[[_modelArray objectAtIndex:0] inventoryPackageID]
                                                       andTagId:imageTagObjectSelected.tagId
                                                      andTypeId:imageTagObjectSelected.typeId
                                              andImageTypeOrder:_currentInventoryImage.imageOrderNdx
                                                 andFeatureText:_featuresField.text
                                                 andImageSource:_fileSourceReference
                                                 andSerialNumber:_currentInventoryImage.serialNumber];
            }
        }
        else
        {
            // Image Type wasn't selected.  Set to throw error.
            
            _returnVal = 2;
        }
    }
    else // This is an image edit
    {
        InventoryImageModel *saveChanges = [[InventoryImageModel alloc] init];
        if( 0 == [saveChanges updateImageDataByImageId:_currentInventoryImage.imagesId
                                                 andTagId:imageTagObjectSelected.tagId
                                                andTypeId:imageTagObjectSelected.typeId
                                        andImageTypeOrder:_currentInventoryImage.imageOrderNdx
                                           andFeatureText:_featuresField.text
                                    andInventoryPackageId:_currentInventoryImage.inventoryPackageID
                                        andImageSource:_currentInventoryImage.imageSource])
        {
            _returnVal = 2;
        }
    }

    // Check for failures otherwise segue
    warningCheck doCheck = _returnVal;
    switch(doCheck)
    {
        // Connection isn't active.
        case warningFailedConnection:
        {
            
            [self.activityIndicatorImage stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"No Connection"
                                      message:@"Please connect to the internet and press save again."
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:[self yesButtonTitle], nil];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
            [alertView setTransform:transform];
            
            [alertView show];
        } break;
            
        //User didnt select an image type
        case warningFailedImageType:
        {
            [self.activityIndicatorImage stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Room?"
                                      message:@"Please select what type of image this is."
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:[self yesButtonTitle], nil];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, 80.0);
            [alertView setTransform:transform];
            
            [alertView show];
        }break;
        
        // All is well.  Segue to the next view
        default:
        {
            [self.activityIndicatorImage stopAnimating];
            [self performSegueWithIdentifier:@"segueToHomeDetailsFromImageDetails" sender:self];
        }break;
    };
    // Segue to listing screen and refresh image data.
}

-(NSString *) yesButtonTitle{
    return @"Ok";
}

- (IBAction)pickerDoneButton:(id)sender {
    
    // unhide the save button
    self.saveButton.hidden = FALSE;
    
    //Setup use of animation
    [UIView beginAnimations:nil context:nil];
    // A snappy action time
    [UIView setAnimationDuration:0.3];
    // Setup the location change coordinates
    pickerViewContainer.frame = CGRectMake(0, 800, 320, 396);
    // perform animation.
    [UIView commitAnimations];
}

- (IBAction)imageTypeFieldTouch:(id)sender {
}

// This prevents the keyboard from popping up.
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if( [ textField.restorationIdentifier isEqualToString:@"imageTypeField" ] )
    {
        //dismiss the keyboard if it is up
        [self.activeTextField resignFirstResponder];
        
        // unhide the save button
        self.saveButton.hidden = TRUE;
        
        // Display the view that contains the picker.
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        // Shift the view to these coordinates
        
        if([UIScreen mainScreen].bounds.size.height == 568){
            pickerViewContainer.frame = CGRectMake(0, 232, 320, 226);
        } else{
            pickerViewContainer.frame = CGRectMake(0, 150, 320, 226);
        }
        
        
        [UIView commitAnimations];
        return NO;
    }
    
    return YES;
    
}

- (void)uploadImage
{
    NSLog(@"ImageDetailsViewController : uploadImage");
    

    // Scale the image down to the 3.2 aspect ratio needed.
    float actualHeight = _homeImage.image.size.height;
    float actualWidth = _homeImage.image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 1920.0/1280.0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 1280.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 1280.0;
        }
        else{
            imgRatio = 1920.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 1920.0;
        }
    } else {
        actualHeight = 1280.0;
        actualWidth = 1920.0;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [_homeImage.image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // setting up the URL to post to
    // .6 = %60 image quality
    NSData *imageData = UIImageJPEGRepresentation(img, .6);
    NSString *urlString = @"https://www.origin-clayton-media.com/rest/fileupload.cfm";
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    
    NSString *imageType = [imageTagObjectSelected.typeId stringByReplacingOccurrencesOfString:@"m-" withString:@""];
    //NSString *imageType = @"Mobile";
    NSString *udidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    NSString *finalFileName = [NSString stringWithFormat:@"MOBL1-%@",udidString];
    NSString *imageDirectory = [NSString stringWithFormat:@"/retail/%@/", imageType];

    NSLog(@"%@",finalFileName);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    // First we have to setup the initial content type that defines the type of content expected as a whole as well as the boundary delimiter
    NSString *boundary = @"-----------------------------7de3463020606";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //Next we build out the body of the call.
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageFile\"; filename=\"%@.jpg\"\r\n",finalFileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    
    NSLog(@"%@%@.jpg", imageDirectory, udidString );
    
    // Set the field source reference
    _fileSourceReference = [NSString stringWithFormat:@"%@%@.jpg", imageDirectory, finalFileName];
    
    // Add the form field "imageDirectory" and its value.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageDirectory\"\r\n\r\n%@",imageDirectory] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Now we end with a boundary also followed by two dashes.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // if needed, create authentication connection for request
    [self basicAuthForRequest:request withUsername:@"dirty" andPassword:@"authentication"];
    
    // now lets make the connection to the web
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    // Display the results that the service gives back.
    NSLog(@"%@",returnString);
    
}

- (void)basicAuthForRequest:(NSMutableURLRequest *)request withUsername:(NSString *)username andPassword:(NSString *)password
{
    
    // Cast username and password as CFStringRefs via Toll-Free Bridging
    CFStringRef usernameRef = (__bridge CFStringRef)username;
    CFStringRef passwordRef = (__bridge CFStringRef)password;
    
    // Reference properties of the NSMutableURLRequest
    CFHTTPMessageRef authoriztionMessageRef = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (__bridge CFStringRef)[request HTTPMethod], (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    
    NSLog(@"%@", authoriztionMessageRef);
    
    // Encodes usernameRef and passwordRef in Base64
    CFHTTPMessageAddAuthentication(authoriztionMessageRef, nil, usernameRef, passwordRef, kCFHTTPAuthenticationSchemeBasic, FALSE);
    
    // Creates the 'Basic - <encoded_username_and_password>' string for the HTTP header
    CFStringRef authorizationStringRef = CFHTTPMessageCopyHeaderFieldValue(authoriztionMessageRef, CFSTR("Authorization"));
    
    NSLog(@"%@", authorizationStringRef);
    
    // Add authorizationStringRef as value for 'Authorization' HTTP header
    [request setValue:(__bridge NSString *)authorizationStringRef forHTTPHeaderField:@"Authorization"];
    
    // Cleanup
    //CFRelease(authorizationStringRef);
    //CFRelease(authoriztionMessageRef);
    
}

@end
