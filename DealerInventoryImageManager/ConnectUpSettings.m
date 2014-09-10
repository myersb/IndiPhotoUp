//
//  ConnectUpSettings.m
//  ConnectUp
//
//  Created by Chris Cantley on 7/17/14.
//  Copyright (c) 2014 Chris Cantley. All rights reserved.
//

#import "ConnectUpSettings.h"

@implementation ConnectUpSettings


-(NSMutableDictionary *) getSettings{
    
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"ConnectUpSettings.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docfilePath]){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ConnectUpSettings" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:docfilePath error:nil];
    }

    return [NSMutableDictionary dictionaryWithContentsOfFile:docfilePath];
}


-(void) writeToSettings:(NSMutableDictionary *)settings{
    
    // get path info to be used by the following method
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"ConnectUpSettings.plist"];
    
    // Write back to the file (remember, this is a copy of the original.  See -init where the copy was created.
    [settings writeToFile:docfilePath atomically:YES];
    
}

@end
