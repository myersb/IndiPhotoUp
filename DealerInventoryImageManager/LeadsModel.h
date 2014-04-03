//
//  LeadsModel.h
//  Indi PhotoUp
//
//  Created by Chris Cantley on 3/27/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeadsModel : NSObject<NSURLConnectionDelegate>

@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSDictionary *jSON;

- (BOOL) refreshLeadData;
- (BOOL) claimLeadUpdate:(NSString*) independentLeadId;

@end
