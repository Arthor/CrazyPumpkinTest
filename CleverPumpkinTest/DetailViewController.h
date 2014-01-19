//
//  DetailViewController.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightData;

@interface DetailViewController : UIViewController

@property (nonatomic, weak) FlightData *flightData;

- (instancetype)initWithFlightData:(FlightData*)flightData;

@end
