//
//  AppDelegate.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "AppDelegate.h"

#import "FlightsStorage.h"
#import "FlightListViewController.h"

@interface AppDelegate()

@property (nonatomic, strong) FlightListViewController *flightListVC;
@property (nonatomic, strong) FlightsStorage *flightsStorage;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.flightsStorage = [[FlightsStorage alloc] init];
    
    self.flightListVC = [FlightListViewController new];
    self.flightListVC.flightsStorage = self.flightsStorage;
    
    self.window.rootViewController = self.flightListVC;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
