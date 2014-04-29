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

@interface EmailLeadViewController : GAITrackedViewController <MFMailComposeViewControllerDelegate>

- (IBAction)actionEmailComposer;
@property (strong, nonatomic) IBOutlet UITextView *tvMessageBody;

@end
