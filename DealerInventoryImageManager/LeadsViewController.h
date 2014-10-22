//
//  LeadsViewController.h
//  Indi PhotoUp
//
//  Created by Chris Cantley on 4/4/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface LeadsViewController : GAITrackedViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSString *isNewLeads;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIAlertView *alert;


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)changeDealerButton:(id)sender;
//toChangeDealerFromLeadsView

- (IBAction)LeadStateButton:(id)sender;

- (IBAction)inventoryViewButton:(id)sender;
//toInventoryViewFromLeadsView

-(NSFetchedResultsController *) fetchedResultsController;
-(void) refreshData;

@end
