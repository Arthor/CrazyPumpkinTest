//
//  FlightListViewController.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightsStorage;

@interface FlightListViewController : UIViewController

@property (nonatomic, weak) FlightsStorage *flightsStorage;

@end
