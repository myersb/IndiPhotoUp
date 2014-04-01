//
//  DealerSelectViewController.m
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 2/19/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "DealerSelectViewController.h"
#import "InventoryViewController.h"
#import "LotInfo.h"


@interface DealerSelectViewController ()

@end

@implementation DealerSelectViewController

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

	id delegate = [[UIApplication sharedApplication]delegate];
	self.managedObjectContext = [delegate managedObjectContext];
	
	[self loadLotInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLotInfo
{
	_fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:@"LotInfo" inManagedObjectContext:[self managedObjectContext]];
	_dealerNumberSort = [NSSortDescriptor sortDescriptorWithKey:@"dealerNumber" ascending:YES];
	
	_sortDescriptors = [[NSArray alloc] initWithObjects:_dealerNumberSort, nil];
	
	[_fetchRequest setEntity:_entity];
	[_fetchRequest setSortDescriptors:_sortDescriptors];
	
	NSError *error = nil;
	_lotArray = [[self managedObjectContext] executeFetchRequest:_fetchRequest error:&error];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lotArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	LotInfo	*lotInfo = [_lotArray objectAtIndex:indexPath.row];
	
	cell.textLabel.text = lotInfo.name;
	cell.detailTextLabel.text = lotInfo.dealerNumber;
	
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	
	if ([[segue identifier] isEqualToString:@"segueFromDealerSelectToIventoryView"]) {
		InventoryViewController *ivc = [segue destinationViewController];
		NSIndexPath *indexPath = [_lotTableView indexPathForSelectedRow];
		LotInfo *lot = [_lotArray objectAtIndex:indexPath.row];
		ivc.chosenDealerNumber = lot.dealerNumber;
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
									   initWithTitle:@"Select"
									   style:UIBarButtonItemStylePlain
									   target:nil
									   action:nil];
		self.navigationItem.backBarButtonItem = backButton;
	}
}

- (void)clearEntity:(NSString *)entityName withFetchRequest:(NSFetchRequest *)fetchRequest
{
	fetchRequest = [[NSFetchRequest alloc]init];
	_entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
	[fetchRequest setEntity:_entity];
	
	NSError *error = nil;
	NSArray* result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *object in result) {
		[[self managedObjectContext] deleteObject:object];
	}
	
	NSError *saveError = nil;
	if (![[self managedObjectContext] save:&saveError]) {
		NSLog(@"An error has occurred: %@", saveError);
	}
}

- (IBAction)logout:(id)sender {
	_alert = [[UIAlertView alloc]initWithTitle:@"Confirm Logout" message:[NSString stringWithFormat:@"Are you sure that you want to logout?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
	[_alert show];
	_logoutSegue = NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		_logoutSegue = YES;
		[self clearEntity:@"Dealer" withFetchRequest:_fetchRequest];
		[self performSegueWithIdentifier:@"segueToLoginFromDealerSelect" sender:self];
	}
}
@end
