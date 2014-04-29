//
//  Leads.h
//  Indi PhotoUp
//
//  Created by Chris Cantley on 4/25/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Leads : NSManagedObject

@property (nonatomic, retain) NSString * changed;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * dayPhone;
@property (nonatomic, retain) NSString * dealerNumber;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * independentLeadId;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * leadDate;
@property (nonatomic, retain) NSDate * leadDateOnPhone;
@property (nonatomic, retain) NSString * status;

@end
