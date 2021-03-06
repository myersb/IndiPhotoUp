//
//  CameraViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 11/1/13.
//  Copyright (c) 2013 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOverlayView.h"
#import "GAITrackedViewController.h"

@interface CameraViewController : GAITrackedViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

// UI Properties
@property (strong, nonatomic) IBOutlet CameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) UIImage *capturedImage;
@property (strong, nonatomic) UIImage *imageToSave;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectPhoto;
@property (strong, nonatomic) IBOutlet UIButton *doneEditingImageBtn;
@property (strong, nonatomic) IBOutlet UIButton *editImageBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *selectPhotoBtn;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) IBOutlet UIView *editingControlerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UILabel *lblSerialNumber;

// Image filtering properties
@property (strong, nonatomic) CIContext *coreImageContext;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSURL *fileNameAndPath;
@property (strong, nonatomic) CIImage *beginImage;
@property (strong, nonatomic) CIFilter *gammaFilter;
@property (strong, nonatomic) CIFilter *exposureFilter;

// Variable Properties
@property (assign) BOOL alertIsShowing;		// Flag to determine if the alert is showing
@property (assign) BOOL endAlerts;
@property (assign) BOOL showAlert;			// Flag to determine whether the alert should be shown
@property (assign) BOOL shouldShowCameraOverlay;
@property (nonatomic, strong) UIAlertView *alert;
@property (strong, nonatomic) NSString *selectedSerialNumber;

// Actions
- (IBAction)savePhoto;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)dismissCameraView:(UIButton *)sender;
- (IBAction)exposureSliderValueDidChange:(UISlider *)slider;
@end
