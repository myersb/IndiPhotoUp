//
//  EmailLeadViewController.m
//  Indi PhotoUp
//
//  Created by Benjamin Myers on 4/17/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "EmailLeadViewController.h"

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
		NSArray *toRecipients = [NSArray arrayWithObjects:@"ben.myers@claytonhomes.com",@"chris.cantley@claytonhomes.com", nil];
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
	[self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
