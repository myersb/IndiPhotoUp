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
#define webServiceLoginURL @"https://claytonupdatecenter.com/cfide/remoteInvoke.cfc?"


@interface LeadsModel()
{
    Reachability *internetReachable;
    BOOL processSuccess;
}
@end

@implementation LeadsModel


- (void) checkOnlineConnection {
    NSLog(@"HomeDetailsViewController : checkOnlineConnection");
	
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    [internetReachable startNotifier];
    
    // Internet is not reachable
    // NOTE - change "reachableBlock" to "unreachableBlock"
    
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
		_isConnected = NO;
    };
	
	internetReachable.reachableBlock = ^(Reachability*reach)
    {
		_isConnected = YES;
    };
    
    // For whatever reason, it requires hitting this once to get it to set right.
    NSLog(_isConnected ? @"Yes" : @"No");
    
}



- (BOOL) refreshLeadData{
    NSLog(@"LeadsModel : refreshLeadDataForDealer");
    
    [self checkOnlineConnection];
    NSLog(_isConnected ? @"Yes" : @"No");
    
    NSString *dealerNumber;
    
    //Checks that the user is online before processing
    if (_isConnected)
    {
        
        
        NSString *getTopLeadDate;
        

        // Creates a pointer to the AppDelegate
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        
        
        
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
            NSLog(@"problem! dealerData fetch is nil : %@", errorDealer);
            return NO;
        }
        
        if (dealerData.count == 0)
        {
            NSLog(@"No dealer record to get leads from");
            return NO;
        } else {
            dealerNumber = [dealerData[0] dealerNumber];
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
            NSLog(@"problem! Fetched objects is nil : %@", error);
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
        
        // Create request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        // Setup Post Body
        NSString *stringImageURL = [NSString stringWithFormat:@"%@method=processGetJSONArray&obj=retail&MethodToInvoke=PrcIndependentLeadsRead&key=KjZUPTdFJ0s2RDM%%2BKVsgICAK&dealernumber=%@&lastCheckedDate=%@&isMobile=%@", webServiceLoginURL, dealerNumber, getTopLeadDate, @"1"];
        NSURL *url = [NSURL URLWithString:stringImageURL];
        NSData *leadData = [NSData dataWithContentsOfURL:url];
        
        //NSString *convertedString = [[NSString alloc] initWithData:leadData encoding:NSUTF8StringEncoding];
        //NSLog(@"Did receive data : %@", convertedString );
        
        
        _jSON = [NSJSONSerialization JSONObjectWithData:leadData options:kNilOptions error:nil];
        _dataDictionary = [_jSON objectForKey:@"data"];
        
        
        // *** Loop over that data and put into the database ***
        for (NSDictionary *imageDictionary in _dataDictionary) {
            
            
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
        
        
        
        
        return YES;
    }
    else
    {
        NSLog(@"Not online");
        return NO;
    }
}






@end
