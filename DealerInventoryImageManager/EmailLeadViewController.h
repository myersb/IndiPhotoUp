//
//  EmailLeadViewController.h
//  Indi PhotoUp
//
//  Created by Benjamin Myers on 4/17/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GAITrackedViewController.h"
#import "Leads.h"

@interface EmailLeadViewController : GAITrackedViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

// UI Properties
@property (strong, nonatomic) IBOutlet UITextView *tvMessageBody;
@property (strong, nonatomic) UIAlertView *alert;

// Variable Properties
@property (strong, nonatomic) Leads *leadToPassBack;

// Actions
- (IBAction)actionEmailComposer;

@end
