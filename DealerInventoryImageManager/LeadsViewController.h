//
//  LeadsViewController.h
//  Indi PhotoUp
//
//  Created by Chris Cantley on 4/4/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeadsViewController : UIViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


@property(nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)changeDealerButton:(id)sender;
//toChangeDealerFromLeadsView


- (IBAction)inventoryViewButton:(id)sender;
//toInventoryViewFromLeadsView

@end
