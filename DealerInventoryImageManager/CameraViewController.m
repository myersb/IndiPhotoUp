//
//  CameraViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 11/1/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import "CameraViewController.h"
#import "ImageDetailsViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_lblSerialNumber.text = _selectedSerialNumber;
	[self prefersStatusBarHidden];
	_alert.delegate = self;
	if (_imageView.image) {
		_saveBtn.hidden = NO;
	}
	else{
		_saveBtn.hidden = YES;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged
{
	
	// Creat orientation object
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// If orientation is landscape remove alert but if user rotates back to portrait show alert
	if (_endAlerts != YES) {
		if((orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) && _alertIsShowing == YES)
		{
			[self performSelector:@selector(dismissAlert:) withObject:_alert afterDelay:0.1];
			_alertIsShowing = NO;
			_showAlert = YES;
			
			[self prefersStatusBarHidden];
		}
		else if(_showAlert == YES && _alertIsShowing == NO && orientation == 1)
		{
			_alert = [[UIAlertView alloc]initWithTitle:@"Check Device Orientation" message:@"Please rotate your phone to the horizontal/landscape orientation" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
			[_alert show];
			
			_alertIsShowing = YES;
			_showAlert = NO;
		}
	}
}

- (void)dismissAlert:(UIAlertView *)alert{
	[alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)presentCameraView:(id)sender {
	
	_editingControlerView.hidden = TRUE;
	_doneEditingImageBtn.hidden = TRUE;
	_picker = [[UIImagePickerController alloc] init];
	_picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	// Set flag to allow the alert to be shown
	_showAlert = YES;
	_endAlerts = NO;
	
	_overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] objectAtIndex:0];
	_overlay.frame = _picker.cameraOverlayView.frame;
	[self prefersStatusBarHidden];
	_picker.delegate = self;
	_picker.allowsEditing = NO;
	_picker.cameraOverlayView = _overlay;
	_picker.showsCameraControls = NO;
	CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 0.0); //This slots the preview exactly in the middle of the screen by moving it down 71 points
    CGAffineTransform scale = CGAffineTransformScale(translate, 0.8888889, 1);
    _picker.cameraViewTransform = scale;
	[self presentViewController:_picker animated:YES completion:NULL];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:@"UIDeviceOrientationDidChangeNotification" object:[UIDevice currentDevice]];
	
	if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && _showAlert == YES && _alertIsShowing == NO) {
		_alert = [[UIAlertView alloc]initWithTitle:@"Check Device Orientation" message:@"Please rotate your phone to the horizontal/landscape orientation" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
		
		[_alert show];
		_alertIsShowing = YES;
		_showAlert = NO;
	}
}

- (IBAction)selectPhoto:(id)sender {
	[_spinner startAnimating];
	_spinner.hidden = FALSE;
	_editingControlerView.hidden = TRUE;
	_doneEditingImageBtn.hidden = TRUE;
	
	_picker = [[UIImagePickerController alloc]init];
	_picker.delegate = self;
	_picker.allowsEditing = NO;
	_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

	[self presentViewController:_picker animated:YES completion:NULL];
}

- (IBAction)takePhoto:(UIButton *)sender {
	[_picker takePicture];
	_endAlerts = YES;
}

- (IBAction)dismissCameraView:(UIButton *)sender {
	[_picker dismissViewControllerAnimated:YES completion:nil];
	_endAlerts = YES;
}

- (IBAction)editImage:(id)sender {
	
	_editingControlerView.hidden = FALSE;
	_doneEditingImageBtn.hidden = FALSE;
	_editImageBtn.hidden = TRUE;
	_beginImage = [CIImage imageWithCGImage:_imageView.image.CGImage];
	
	_coreImageContext = [CIContext contextWithOptions:nil];
	
	//_gammaFilter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, _beginImage, @"inputPower", @0.75, nil];
	
	_exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, _beginImage, @"inputEV", @0.5, nil];
}

- (IBAction)stopEditingImage:(id)sender {
	_editingControlerView.hidden = TRUE;
	_doneEditingImageBtn.hidden = TRUE;
	_editImageBtn.hidden = FALSE;
}

//- (IBAction)gammaSliderValueDidChange:(UISlider *)slider {
//	float slideValue = slider.value;
//	NSLog(@"Gamma: %f", slideValue);
//	
//	UIImageOrientation originalOrientation = _imageView.image.imageOrientation;
//	CGFloat originalScale = _imageView.image.scale;
//	
//	[_gammaFilter setValue:_beginImage forKeyPath:kCIInputImageKey];
//	[_gammaFilter setValue:@(slideValue) forKey:@"inputPower"];
//	
//	CIImage *outputImage = [_gammaFilter outputImage];
//	CGImageRef cgimg = [_coreImageContext createCGImage:outputImage fromRect:[outputImage extent]];
//	UIImage *alteredImage = [UIImage imageWithCGImage:cgimg scale:originalScale orientation:originalOrientation];
//	
//	_imageView.image = alteredImage;
//	
//	CGImageRelease(cgimg);
//}

- (IBAction)exposureSliderValueDidChange:(UISlider *)slider {
	float slideValue = slider.value;
	
	UIImageOrientation originalOrientation = _imageView.image.imageOrientation;
	CGFloat originalScale = _imageView.image.scale;
	
	[_exposureFilter setValue:_beginImage forKeyPath:kCIInputImageKey];
	[_exposureFilter setValue:@(slideValue) forKey:@"inputEV"];
	
	CIImage *outputImage = [_exposureFilter outputImage];
	CGImageRef cgimg = [_coreImageContext createCGImage:outputImage fromRect:[outputImage extent]];
	UIImage *alteredImage = [UIImage imageWithCGImage:cgimg scale:originalScale orientation:originalOrientation];
	
	_imageView.image = alteredImage;
	
	CGImageRelease(cgimg);
}


- (IBAction)savePhoto {
	//UIImageWriteToSavedPhotosAlbum([_imageView image], nil, nil, nil);
	_endAlerts = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	_editImageBtn.hidden = FALSE;
	[_spinner stopAnimating];
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	_showAlert = NO;
	_alertIsShowing = NO;
	
	_selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	int yCoord = (_selectedImage.size.height - ((_selectedImage.size.width*2)/3))/2;
	UIImage *croppedImage = [self cropImage:_selectedImage andFrame:CGRectMake(0, yCoord, _selectedImage.size.width, ((_selectedImage.size.width*2)/3))];
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_endAlerts = YES;
		UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
	}
	_imageView.image = croppedImage;
	
	_saveBtn.hidden = NO;
}

- (UIImage *)cropImage:(UIImage*)image andFrame:(CGRect)rect {
	
	//Note : rec is nothing but the image frame which u want to crop exactly.
	
    rect = CGRectMake(rect.origin.x*image.scale,
                      rect.origin.y*image.scale,
                      rect.size.width*image.scale,
                      rect.size.height*image.scale);
	
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:image.scale
                                    orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker dismissViewControllerAnimated:YES completion:NULL];
	
	[self performSelector:@selector(dismissAlert:) withObject:_alert afterDelay:1.0];
	
	_showAlert = NO;
	_alertIsShowing = NO;
	[_spinner stopAnimating];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"segueFromNewPhotoToImageDetails"]) {
		ImageDetailsViewController *idvc = (ImageDetailsViewController *)[segue destinationViewController];
		idvc.selectedImage = _imageView.image;
		idvc.selectedSerialNumber = _selectedSerialNumber;
		
	}
}

@end
