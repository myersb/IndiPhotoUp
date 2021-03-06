//
//  DealerSelectViewController.h
//  DealerInventoryImageManager
//
//  Created by Benjamin Myers on 2/19/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface DealerSelectViewController : GAITrackedViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSEntityDescription *entity;
@property (nonatomic, strong) NSSortDescriptor *dealerNumberSort;
@property (nonatomic, strong) NSArray *sortDescriptors;

@property (strong, nonatomic) IBOutlet UITextField *tfDealerNumber;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) IBOutlet UIButton *btnLogout;
@property (strong, nonatomic) IBOutlet UITableView *lotTableView;

@property (nonatomic, strong) NSArray *lotArray;

@property (nonatomic) BOOL logoutSegue;

- (IBAction)logout:(id)sender;
@end
