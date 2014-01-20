//
//  FlightInfoCell.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightInfoCell.h"

#import "FlightData.h"

@implementation FlightInfoCell

- (void)configureForFlight:(FlightData*)flightData
{
    self.landingDate.text = flightData.landingDate;
    self.landingTime.text = flightData.landingHour;
    self.takeoffDate.text = flightData.takeoffDate;
    self.takeoffTime.text = flightData.takeoffHour;
    self.carrier.text = flightData.carrier;
    self.number.text = @( flightData.number ).stringValue;
    self.price.text = @( flightData.price ).stringValue;
    self.flightDuration.text = flightData.flightDuration;
}

@end
