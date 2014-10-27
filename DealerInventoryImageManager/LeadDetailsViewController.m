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
	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
    
    [self fillLabel];
	[self markAsRead];
	self.title = @"Lead Details";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fillLabel
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd yyyy"];
    NSString *leadDateOnPhone = [dateFormat stringFromDate:_selectedLead.leadDateOnPhone];
    
    NSString *tempString = [NSString stringWithFormat:@"%@", _selectedLead.comments];
    
    [_fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", _selectedLead.firstName, _selectedLead.lastName ]];
    [_commentsText setText:[NSString stringWithFormat:@"%@", tempString]];
    [_leadDateText setText:[NSString stringWithFormat:@"%@", leadDateOnPhone]];
    [_phoneText setText:[NSString stringWithFormat:@"%@", _selectedLead.dayPhone]];
    [_emailText setTitle:[NSString stringWithFormat:@"%@", _selectedLead.email ] forState:UIControlStateNormal];
}

- (void)markAsRead
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Leads" inManagedObjectContext:[self managedObjectContext]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"independentLeadId == %@", _selectedLead.independentLeadId];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	Leads *leadToChange = [result objectAtIndex:0];
	[leadToChange setValue:@"c" forKeyPath:@"status"];
	
	
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
		_alert = [[UIAlertView alloc]initWithTitle:@"Cannot Send Email" message:@"Please verify that you have an internet connection and that you have an email account properly setup on your device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[_alert show];
		//NSLog(@"Device is unable to send email in its current state.");
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
