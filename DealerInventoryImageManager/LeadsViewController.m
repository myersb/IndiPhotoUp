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


@interface LeadsViewController ()

@end

@implementation LeadsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

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
    self.screenName = @"LeadsViewController";

    
    //load up - retrieves new leads.
    LeadsModel *leadsModel = [[LeadsModel alloc]init];
    [leadsModel refreshLeadData];
	[self.tableView reloadData];
    
    NSLog(@"ready");
    

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error! %@",error);
        abort();
    }

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections]count];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *getSection = [[[self.fetchedResultsController sections]objectAtIndex:section]name];
    
    if ([getSection isEqualToString:@"n"])
    {
        getSection = @"New Leads";
    } else {
        getSection = @"Viewed Leads";
    }
        
    
    return getSection;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSLog(@"Sections: %lu", (unsigned long)[secInfo numberOfObjects]);
    return [secInfo numberOfObjects];
}


-(CGFloat) tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lblLeadSection = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    lblLeadSection.textColor = [self colorFromHexString:@"#ffffff"];
   
    NSString *getSection = [[[self.fetchedResultsController sections]objectAtIndex:section]name];
    if ([getSection isEqualToString:@"n"])
    {
        lblLeadSection.backgroundColor = [self colorFromHexString:@"#B3BBE3"];
        lblLeadSection.text = @"  New Leads";
    } else {
        lblLeadSection.backgroundColor = [self colorFromHexString:@"#B3E3B5"];
        lblLeadSection.text = @"  Viewed Leads";
    }
    
    return lblLeadSection;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
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
-(NSFetchedResultsController *) fetchedResultsController {
    
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Leads"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortStatus = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:NO];
    NSSortDescriptor *sortLeadDate = [[NSSortDescriptor alloc] initWithKey:@"leadDate" ascending:NO];
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
        [leadModel claimLead:leadObj.independentLeadId];
        

        
        // Get the destination class file for the target view
        LeadDetailsViewController *ldvc = [segue destinationViewController];
        [ldvc setSelectedLead:leadObj];
 
        
    }
}


#pragma mark - Actions


- (IBAction)changeDealerButton:(id)sender {
    [self performSegueWithIdentifier:@"toChangeDealerFromLeadsView" sender:self];
}

- (IBAction)inventoryViewButton:(id)sender {
    [self performSegueWithIdentifier:@"toInventoryViewFromLeadsView" sender:self];
}
@end
