//
//  LotInfo.h
//  Indi PhotoUp
//
//  Created by Benjamin Myers on 3/27/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LotInfo : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * dealerNumber;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * phone;

@end
