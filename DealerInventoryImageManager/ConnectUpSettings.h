//
//  ConnectUpSettings.h
//  ConnectUp
//
//  Created by Chris Cantley on 7/17/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectUpSettings : NSObject


-(NSMutableDictionary *) getSettings;
-(void) writeToSettings:(NSMutableDictionary *)settings;
    
@end
