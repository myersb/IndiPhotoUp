//
//  LeadsModel.m
//  Indi PhotoUp
//
//  Created by Chris Cantley on 3/27/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "LeadsModel.h"
#import "Leads.h"
#import "Reachability.h"
#import "Dealer.h"

#define modelListDataSector @"data"

// JSON Header for Dealer data
//
#define JSON_LEAD_INDEPENDENTLEADID @"independentleadid"
#define JSON_LEAD_DAYPHONE @"dayphone"
#define JSON_LEAD_EMAIL @"email"
#define JSON_LEAD_FIRSTNAME @"firstname"
#define JSON_LEAD_LASTNAME @"lastname"
#define JSON_LEAD_COMMENTS @"comments"
#define JSON_LEAD_STATUS @"status"
#define JSON_LEAD_LEADDATE @"leaddate"
#define JSON_LEAD_CHANGED @"changed"
#define MINUTES_SINCE_LAST_REFRESH_CHECK ((int) 5)  //Used to force re-login if greater than two hours

//#define webServiceLoginURL @"http://claytonUpdateCenter.pubdev.com/cfide/remoteInvoke.cfc?"
#define webServiceLoginURL @"https://www.claytonupdatecenter.com/cmhapi/connect.cfc?"


@interface LeadsModel()
{
    Reachability *internetReachable;
    BOOL processSuccess;
}
@end

@implementation LeadsModel

-(id) init{
    
    
    // If the plist file doesn't exist, copy it to a place where it can be worked with.
    // Setup settings to contain the data.
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"ConnectUpSettings.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // use to delete and reset app.
    //[fileManager removeItemAtPath:docfilePath error:NULL];
    
    if (![fileManager fileExistsAtPath:docfilePath]){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ConnectUpSettings" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:docfilePath error:nil];
    }
    self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:docfilePath];
    
    
    return self;
}


- (BOOL) refreshLeadData{
    //NSLog(@"LeadsModel : refreshLeadDataForDealer");
    
    //internetReachable = [[Reachability alloc] init];
    //[internetReachable checkOnlineConnection];
    //NSLog(internetReachable.isConnected ? @"Yes" : @"No");
    
    NSString *dealerNumber;  //= @"290844"; // remove if dealernumber is here
    
    [self refreshLeadBadge];
    
    
    //Checks that the user is online before processing
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
    {
        
        NSString *getTopLeadDate;
        
        
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        
        
        if (dealerNumber == nil)  // This is here for testing purposes as we could put a dealer number into the system and skip the process of getting it from the DB.
        {
            
            // Fetch the users dealerNumber.
            NSFetchRequest *fetchRequestDealerNumber = [[NSFetchRequest alloc] init];
            // setup the entity assignement
            NSEntityDescription *entityDealer = [NSEntityDescription entityForName:@"Dealer"
                                                            inManagedObjectContext:self.managedObjectContext];
            [fetchRequestDealerNumber setEntity:entityDealer];
            
            NSError *errorDealer = nil;
            NSArray *dealerData = [self.managedObjectContext executeFetchRequest:fetchRequestDealerNumber error:&errorDealer];
            
            
            if (dealerData == nil)
            {
                //NSLog(@"problem! dealerData fetch is nil : %@", errorDealer);
                return NO;
            }
            
            if (dealerData.count == 0)
            {
                //NSLog(@"No dealer record to get leads from");
                return NO;
            } else {
                dealerNumber = [dealerData[0] dealerNumber];
            }
        }
        
        // *** get the most recent lead date. ***
        
        // setup the fetch Request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        
        // setup the entity assignement
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Leads"
                                                  inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        // setup the sort on the fetch request
        NSSortDescriptor *sortLastCheckedDate = [NSSortDescriptor sortDescriptorWithKey:@"leadDate" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortLastCheckedDate, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        
        
        
        if (fetchedObjects == nil)
        {
            //NSLog(@"problem! Fetched objects is nil : %@", error);
            return NO;
        }
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        
        // Check for records, and if none exist, get the last three months worth of leads.  Otherwise use the top lead date.
        if (fetchedObjects.count == 0)
        {
            
            NSDate *currDate = [NSDate date];
            
            // Take away 3 months from current date   (subtract 90 days)
            NSDate *startTimePeriod = [currDate dateByAddingTimeInterval:-90*24*60*60];
            
            // Format the date
            
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            getTopLeadDate = [dateFormatter stringFromDate:startTimePeriod];
            
        }
        else
        {
            // Get the top leadDate which will be used to fetch more recent leads.
            getTopLeadDate = [fetchedObjects[0] leadDate];
            
            // Have to replace spaces in the variable or it wont work.
            getTopLeadDate = [getTopLeadDate stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            //NSLog(@"Top Lead Date : %@", getTopLeadDate );
        }
        
        
        // *** Setup call to API. ***
        
        // Setup params
        NSString *urlString = [NSString stringWithFormat:@"%@", webServiceLoginURL];
        NSString *function = @"PrcIndependentLeadsRead";
        NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
        
        // Create request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        // Setup Post Body
        NSString *stringImageURL = [NSString stringWithFormat:@"%@method=gateway&function=%@&accesstoken=%@&dealerNumber=%@&lastCheckedDate=%@&isMobile=%@",
                                    
                                    webServiceLoginURL,
                                    function,
                                    accessToken,
                                    
                                    dealerNumber,
                                    getTopLeadDate,
                                    @"1"
                                    ];
        
        
        //NSString *stringImageURL = [NSString stringWithFormat:@"%@method=processGetJSONArray&obj=retail&MethodToInvoke=PrcIndependentLeadsRead&key=KjZUPTdFJ0s2RDM%%2BKVsgICAK&dealernumber=%@&lastCheckedDate=%@&isMobile=%@", webServiceLoginURL, dealerNumber, getTopLeadDate, @"1"];
        NSURL *url = [NSURL URLWithString:stringImageURL];
        NSData *leadData = [NSData dataWithContentsOfURL:url];
        
        //NSLog(@"%@", url);
        
        //NSString *convertedString = [[NSString alloc] initWithData:leadData encoding:NSUTF8StringEncoding];
        //NSLog(@"Did receive data : %@", convertedString );
        
        
        NSError *jsonError;
        _jSON = [NSJSONSerialization JSONObjectWithData:leadData options:kNilOptions error:&jsonError];
        //NSLog(@"%@", jsonError);
        
        _dataDictionary = [_jSON objectForKey:@"data"];
		//NSLog(@"%@", _dataDictionary);
        
        
        // *** Loop over that data and put into the database ***
        for (NSDictionary *imageDictionary in _dataDictionary) {
            
            // Check to see if there was an error.
            
            Leads *lead = [NSEntityDescription insertNewObjectForEntityForName:@"Leads" inManagedObjectContext:[self managedObjectContext]];
            
            NSString *dateStr = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"leaddate"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            
            NSString *getStatus = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"status"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            
            
            
            
            // Convert string to date object
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd H:mm:ss.SS"];
            [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
            //[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-0]];
            NSDate *leadDateFormatted = [dateFormat dateFromString:dateStr];
            
            // Evaluate the status and put in a default value if not yet claimed
            if ( getStatus == (id)[NSNull null] || [getStatus isEqualToString:@"null"])
            {
                getStatus = [NSString stringWithFormat:@"n"]; // "n" meaning "not yet claimed".
            } else {
                getStatus = [NSString stringWithFormat:@"c"]; // "c" meaning "claimed".
            }
            
            
            // Put it all in the object.
            lead.independentLeadId = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"independentleadid"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.dayPhone = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"dayphone"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.email =  [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"email"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.dealerNumber = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"dealernumber"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.firstName = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"firstname"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.lastName = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"lastname"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.comments = [NSString stringWithFormat:@"%@",[NSLocalizedString([imageDictionary objectForKey:@"comments"], nil) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            lead.status = getStatus;
            lead.leadDateOnPhone = leadDateFormatted;
            lead.leadDate = dateStr;
            lead.changed = [NSString stringWithFormat:@"1"];
            
        }
        
        NSError *insertDataError;
        [_managedObjectContext save:&insertDataError];
        
        
        // Reset the badge count that is over the icon.
        [self refreshLeadBadge];
        return YES;
        
    }
    else
    {
        //NSLog(@"Not online");
        return NO;
    }
    
    
}


- (BOOL) claimLeadUpdate:(NSString*) independentLeadId withStatus:(NSString*) status{
    
    // NOTE : Status can be "c" for 'claimed' or "I" for 'Ignore'.  Ignore is like deleting in that it is removed from the DB.
    
    //NSLog(@"LeadsModel : claimLeadUpdate");
    
    
    //Checks that the user is online before processing
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
    {
        
        // *** Send change to remote server ***
        
        // *** Setup call to API. ***
        
        // Setup params
        NSString *urlString = [NSString stringWithFormat:@"%@", webServiceLoginURL];
        
        // Create request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        

         
        NSString *function = @"prcIndependentLeadReassignmentUpdate";
        NSString *accessToken = [self.settings objectForKey:@"AccessToken"];
        
        // Setup Post Body
        //NSString *stringImageURL = [NSString stringWithFormat:@"%@method=processGetJSONArray&obj=retail&MethodToInvoke=prcIndependentLeadReassignmentUpdate&key=KjZUPTdFJ0s2RDM%%2BKVsgICAK&IndependentLeadID=%@&status%@", webServiceLoginURL, independentLeadId, status];
        NSString *stringImageURL = [NSString stringWithFormat:@"%@method=gateway&function=%@&accesstoken=%@&IndependentLeadID=%@&status=%@",
                                    
                                    webServiceLoginURL,
                                    function,
                                    accessToken,
                                    
                                    independentLeadId,
                                    status
                                    ];
        
        NSURL *url = [NSURL URLWithString:stringImageURL];
        NSData *leadData = [NSData dataWithContentsOfURL:url];
        
        //NSString *convertedString = [[NSString alloc] initWithData:leadData encoding:NSUTF8StringEncoding];
        //NSLog(@"Did receive data : %@", convertedString);
        
        // Check to see if the return of data has anything in it that is parsable.  If not, then return NO.
        @try {
            _jSON = [NSJSONSerialization JSONObjectWithData:leadData options:kNilOptions error:nil];
            _dataDictionary = [_jSON objectForKey:@"data"];
        }
        @catch (NSException * e) {
            //NSLog(@"Exception: %@", e);
            return NO; // This isn't working.
        }
        @finally {
            NSLog(@"finally");
        }
        
        
        
        // *** Put change into CordData ***
        // Creates a pointer to the AppDelegate
        
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        
        // Data object call
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Leads"];
        
        // Setup filter
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"independentLeadId==%@",independentLeadId];
        fetchRequest.predicate=predicate;
        
        // Put data into new object based on filtered fetch request.
        NSArray *updateLeadData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
        
        
        // Check that there is a lead and if so, then decide whether to delete it or Claim it.
        @try {
            Leads *lead = [updateLeadData objectAtIndex:0];
            
            if ([status isEqualToString:@"c"] )
            {
                lead.status = status;
                
                NSError *errorLead = nil;
                [self.managedObjectContext save:&errorLead];
                
            } else {
                
                [self.managedObjectContext deleteObject:lead ];
            }
        }
        @catch (NSException * e) {
            //NSLog(@"Lead doesn't exist in DB : Exception: %@", e);
            return NO; // This isn't working.
        }
        @finally {
            NSLog(@"");
        }
        
        
        [self refreshLeadBadge];
        
        return YES;
    }
    else
    {
        //NSLog(@"Not online");
        return NO;
    }
}

- (void) deleteAllLeads{
    
    
    // Clear out old data to prepare for data refresh.
    // --------------------------------------------------
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // Data object call
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Leads"];
    
   
    // Put data into new object based on filtered fetch request.
    NSArray *deleteLeadData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    
    // Loop over the results and delete each object.
    for (id object in deleteLeadData) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self refreshLeadBadge];
    
}


// This sets the lead to "ignore" in the remote database (api) and removes it from core data
- (BOOL) deleteLead: (NSString*) independentLeadId
{
    return [self claimLeadUpdate:independentLeadId withStatus:@"I"  ];
    
}

// Sets the lead to "c" claimed, categorizing it as no longer "new"
- (BOOL) claimLead: (NSString*) independentLeadId
{
    return [self claimLeadUpdate:independentLeadId withStatus:@"c"  ];
}



// Fetches a number or records starting at a certain record.  This can be used to return all or increments where the design might want to only load a portion at a time.
- (NSArray*) getAllLeadsStartingAt: (NSNumber*) startingAt forHowMany: (NSNumber*) howMany

{
    // *** Put change into CordData ***
    // Creates a pointer to the AppDelegate
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    
    //setup the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    //setup the entity assignment
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Leads"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortStatus = [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES];
    NSSortDescriptor *sortLeadDateOnPhone = [NSSortDescriptor sortDescriptorWithKey:@"leadDateOnPhone" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortStatus, sortLeadDateOnPhone, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSArray *getLeads = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    
    
    NSInteger i;
    NSInteger start = [startingAt intValue]  ;
    NSInteger to = [startingAt intValue] + [howMany intValue] ;
    
    NSMutableArray *leadsFiltered = [[NSMutableArray alloc] initWithCapacity:to];
    
    // Check to see if we have exceded the number of records in our "to" count.  If we have, then make it the count.
    if ([getLeads count] < to){
        to = getLeads.count;
    }
    
    // Only loop over the records based on the "start" and "to"
    for (i = start; i < to; i++)
    {
        id getLeadRecord = [getLeads objectAtIndex:i];
        
        // put each object into an array
        [leadsFiltered addObject:getLeadRecord];
    }
    
    // and serve that array out.
    return leadsFiltered;
    
}




-(void) refreshLeadBadge{
    //NSLog(@"LeadsModel : refreshLeadBadge");
    
    // Get a count of all objects under section 0 (the first section)
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    // Data object call
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Leads"];
    
    // Setup filter
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status==%@", @"n"];
    fetchRequest.predicate=predicate;
    
    // Put data into new object based on filtered fetch request.
    NSArray *readData = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil] ;
    
    // Refresh the icon badge.
    [UIApplication sharedApplication].applicationIconBadgeNumber = [readData count];
    
    //NSLog(@"Number of New Leads : %lu", (unsigned long)readData.count);
    
}







@end