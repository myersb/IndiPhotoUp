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
    [_emailText setTitle:[NSString stringWithFormat:@"%@ -->", _selectedLead.email ] forState:UIControlStateNormal];

    
}



- (IBAction)actionEmailComposer
{
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc]init];
		mailViewController.mailComposeDelegate = self;
		NSArray *toRecipients = [NSArray arrayWithObjects:@"ben.myers@claytonhomes.com",_selectedLead.email, nil];
		[mailViewController setToRecipients:toRecipients];
		[mailViewController setSubject:@"Subject Goes Here"];
		
		[self presentViewController:mailViewController animated:YES completion:nil];
	} else {
		NSLog(@"Device is unable to send email in its current state.");
	}
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	if (result != MFMailComposeResultCancelled) {
		
		_alert = [[UIAlertView alloc]initWithTitle:@"Message Sent" message:[NSString stringWithFormat:@"Your message was successfully sent."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[_alert show];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
