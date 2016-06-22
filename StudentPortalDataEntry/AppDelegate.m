//
//  AppDelegate.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 10/27/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [Parse setApplicationId:@"wVRZavzu8nWrCXqARfeDpJuQkmAZ6Y3bCi6oQe6A" clientKey:@"dhCUaW995HXG0Nw7FU8KBc35YrtQ7iWboOxjXO3P"];
}

@end
