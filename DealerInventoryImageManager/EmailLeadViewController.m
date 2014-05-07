//
//  EmailLeadViewController.m
//  Indi PhotoUp
//
//  Created by Benjamin Myers on 4/17/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "EmailLeadViewController.h"
#import "LeadDetailsViewController.h"

@interface EmailLeadViewController ()

@end

@implementation EmailLeadViewController

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
    self.screenName = @"EmailLeadViewController";
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionEmailComposer
{
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc]init];
		mailViewController.mailComposeDelegate = self;
		NSArray *toRecipients = [NSArray arrayWithObjects:@"ben.myers@claytonhomes.com",_leadToPassBack.email, nil];
		[mailViewController setToRecipients:toRecipients];
		[mailViewController setSubject:@"Subject Goes Here"];
		[mailViewController setMessageBody:_tvMessageBody.text isHTML:NO];
		
		[self presentViewController:mailViewController animated:YES completion:nil];
	} else {
		NSLog(@"Device is unable to send email in its current state.");
	}
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	_alert = [[UIAlertView alloc]initWithTitle:@"Message Sent" message:[NSString stringWithFormat:@"Your message was successfully sent."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[_alert show];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self performSegueWithIdentifier:@"returnToLeads" sender:self];
}


//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"returnToLeads"]) {
//		LeadDetailsViewController *ldvc = [segue destinationViewController];
//		
//		ldvc.selectedLead = _leadToPassBack;
//	}
//}


@end
