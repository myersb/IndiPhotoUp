//
//  LeadDetailsViewController.m
//  Indi PhotoUp
//
//  Created by Chris Cantley on 4/26/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "LeadDetailsViewController.h"
#import "EmailLeadViewController.h"

@interface LeadDetailsViewController ()

@end

@implementation LeadDetailsViewController


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
    
    // This is the google analitics
    self.screenName = @"LeadDetailsViewController";
    
    [self fillLabel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fillLabel {
    
    
    NSLog(@"%@", _selectedLead);
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd yyyy"];
    NSString *leadDateOnPhone = [dateFormat stringFromDate:_selectedLead.leadDateOnPhone];
    
    [_fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", _selectedLead.firstName, _selectedLead.lastName ]];
    [_commentsText setText:[NSString stringWithFormat:@"%@", _selectedLead.comments ]];
    [_leadDateText setText:[NSString stringWithFormat:@"%@", leadDateOnPhone ]];
    [_phoneText setText:[NSString stringWithFormat:@"%@", _selectedLead.dayPhone ]];
    [_emailText setTitle:[NSString stringWithFormat:@"%@", _selectedLead.email ] forState:UIControlStateNormal];

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"segueToEmailLeadView"]) {
		EmailLeadViewController *elvc = [segue destinationViewController];
		
		elvc.leadToPassBack = _selectedLead;
	}
}

@end
