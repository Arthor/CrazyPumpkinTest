//
//  FlightListViewController.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightListViewController.h"

#import "FlightXMLParseOperation.h"
#import "FlightsStorage.h"

@interface FlightListViewController ()<FlightsStorageProtocol>

@end

@implementation FlightListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.flightsStorage fetchNewData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.flightsStorage.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleError:(NSError *)error
{
    
    NSString *errorMessage = [error localizedDescription];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - FlightsStorageProtocol
- (void)flightsUpdated:(NSArray*)updatedFlights
{
    NSLog(@"Updated: %@", updatedFlights);
}

- (void)failedWithError:(NSError*)error
{
    
}

@end
