//
//  LeadDetailsViewController.h
//  Indi PhotoUp
//
//  Created by Chris Cantley on 4/26/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Leads.h"
#import "GAITrackedViewController.h"

@interface LeadDetailsViewController : GAITrackedViewController
{
    Leads *lead;
}

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentsText;
@property (weak, nonatomic) IBOutlet UITextView *leadDateText;
@property (weak, nonatomic) IBOutlet UITextView *phoneText;
@property (weak, nonatomic) IBOutlet UIButton *emailText;

@property (strong, nonatomic) Leads *selectedLead;


@end
