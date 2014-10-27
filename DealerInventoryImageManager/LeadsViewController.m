//
//  LeadsViewController.m
//  Indi PhotoUp
//
//  Created by Chris Cantley on 4/4/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "Leads.h"
#import "LeadsModel.h"
#import "LeadsViewController.h"
#import "LeadDetailsViewController.h"
#import "Reachability.h"
#import "DealerModel.h"


@interface LeadsViewController ()
{
	LeadsModel *leadsModel;
    Reachability *internetReachable;
    DealerModel *dealerModel;

}


@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation LeadsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize isNewLeads = _isNewLeads;



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

    
    // Check to see if user should be sent back to login.
    if (internetReachable.isConnected) {
        
        if ([dealerModel isDealerExpired]) {
            //NSLog(@"Dealer IS expired");
            
            // Send user to login as their Login has expired.
            [self performSegueWithIdentifier:@"toLoginViewFromLeads" sender:self];
        }
        
    }
    

    if (![_isNewLeads isEqualToString:@""]){
        _isNewLeads = @"n";
    }

    
    
    // This is the google analitics
    self.screenName = @"LeadsViewController";
	
    internetReachable = [[Reachability alloc] init];
	[internetReachable checkOnlineConnection];

    
    //load up - retrieves new leads.
    leadsModel = [[LeadsModel alloc]init];
    
    //NSLog(@"ready");
    
    // Get new data and refresh data.

    [leadsModel refreshLeadData];


    

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        //NSLog(@"Error! %@",error);
        abort();
    }

    
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    //NSLog(@"%lu", (unsigned long)[[_fetchedResultsController fetchedObjects] count]);
    
    
}

/*
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
        return YES;
}
*/


-(void) refreshData{
    [leadsModel refreshLeadData];
    [self.refreshControl endRefreshing];
    
}


- (void)viewWillAppear:(BOOL)animated
{

    [_tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_tableView reloadData];
	//[self adjustHeightOfTableview];
}


- (void)adjustHeightOfTableview
{
	if ([[UIScreen mainScreen] bounds].size.height < 568)
	{
		// now set the frame accordingly
		CGRect frame = self.tableView.frame;
		frame.size.height = 364;
		self.tableView.frame = frame;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    return [[_fetchedResultsController fetchedObjects] count];

}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (internetReachable.isConnected) {
			NSManagedObjectContext *context = [self managedObjectContext];
			Leads *leadToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
			
			// Change status of lead.
			LeadsModel *leadModel = [[LeadsModel alloc] init];
			[leadModel deleteLead:leadToDelete.independentLeadId];
			
			// setup to remove from context.
			[context deleteObject:leadToDelete];
			
			// execute to save context changes.
			NSError *error = nil;
			if (![context save:&error]) {
				NSLog(@"Error! %@",error);
			}
			
		} else {
            _alert = [[UIAlertView alloc]initWithTitle:@"No Connection" message:[NSString stringWithFormat:@"A cellular or wifi connection is required for deleting leads. Please connect to a cellular or wireless network and try again."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[_alert show];
        }
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Leads *leads = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", leads.firstName, leads.lastName];
    
    cell.textLabel.text = fullName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd yyyy"];
    cell.detailTextLabel.text = [dateFormat stringFromDate:leads.leadDateOnPhone];
    

    if ([leads.status isEqualToString:@"n"])
    {
        cell.textLabel.textColor = [self colorFromHexString:@"#000000"];
    } else {
        cell.textLabel.textColor = [self colorFromHexString:@"#909090"];
    }
    
    
    return cell;
}




#pragma mark -
#pragma mark Supporting methods
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#pragma mark -
#pragma mark Fetched Results Controller section

// Can be called without the refresh, and will default refresh to 0
-(NSFetchedResultsController *) fetchedResultsController{
    return  [self fetchedResultsController:@"n"];
}

-(NSFetchedResultsController *) fetchedResultsController:(NSString*) refresh{
    

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Leads"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status==%@", refresh];
    fetchRequest.predicate=predicate;
    
    NSSortDescriptor *sortStatus = [[NSSortDescriptor alloc] initWithKey:@"status"
                                                                   ascending:NO];
    NSSortDescriptor *sortLeadDate = [[NSSortDescriptor alloc] initWithKey:@"leadDate"
                                                               ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortStatus, sortLeadDate, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:self.managedObjectContext
                                                                     sectionNameKeyPath:@"status"
                                                                              cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            Leads *changedLead = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", changedLead.firstName, changedLead.lastName];
            
            cell.textLabel.text = fullName;
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"MMM dd yyyy"];
            cell.detailTextLabel.text = [dateFormat stringFromDate:changedLead.leadDateOnPhone];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break; // Not used but put in to remove warning
        case NSFetchedResultsChangeUpdate:
            break; // Not used but put in to remove warning
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    
    if ([[segue identifier]isEqualToString:@"ToLeadDetailsFromLeadList"]) {
        
        
        
        // Get the selected image object and put it into the associated property in the target
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        
        // Figure out what the real data row is based on the row and section.
        NSInteger rowNumber = 0;
        for (NSInteger i = 0; i < path.section; i++) {
            rowNumber += [self.tableView numberOfRowsInSection:i];
        }
        rowNumber += path.row;
        
        // Put the data from the true row into the target object.
        Leads *leadObj = [self.fetchedResultsController objectAtIndexPath:path];
        
        
        // Change status of lead.
        LeadsModel *leadModel = [[LeadsModel alloc] init];
		//NSLog(@"%@", leadObj.independentLeadId);
		if (internetReachable.isConnected) {
			[leadModel claimLead:leadObj.independentLeadId];
		}
        
        // Get the destination class file for the target view
        LeadDetailsViewController *ldvc = [segue destinationViewController];
        [ldvc setSelectedLead:leadObj];
 
        
    } else if ([[segue identifier]isEqualToString:@"toLaunchViewFromLeadsView"]) {
        [dealerModel deleteDealerData];
    }
}


#pragma mark - Actions


- (IBAction)changeDealerButton:(id)sender {
    // segues on toChangeDealerFromLeadsView
}

- (IBAction)LeadStateButton:(id)sender {
    
    // Handle the actions of changing between lead types
    if (_segmentedControl.selectedSegmentIndex == 0){
        _isNewLeads = @"n";
        //[self fetchedResultsController:@"n"];
        
        _fetchedResultsController = nil;
        
        NSError *error = nil;
        if (![[self fetchedResultsController:@"n"] performFetch:&error]) {
            NSLog(@"Error! %@",error);
            abort();
        }
        
        
    }
    if (_segmentedControl.selectedSegmentIndex == 1){
        _isNewLeads = @"c";
        //[self fetchedResultsController:@"C"];
        
        _fetchedResultsController = nil;
        
        NSError *error = nil;
        if (![[self fetchedResultsController:@"c"] performFetch:&error]) {
            NSLog(@"Error! %@",error);
            abort();
        }
    }

    
    
    [_tableView reloadData];
    
    [_tableView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];

}

- (IBAction)inventoryViewButton:(id)sender {
    // segues on toInventoryViewFromLeadsView
}




@end
