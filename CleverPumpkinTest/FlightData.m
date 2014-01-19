//
//  FlightData.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightData.h"

@implementation FlightData

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"Flight from %@ at %@ %@ "
                             "to %@ at %@ %@ by %@ %@. "
                             "Price: %@", self.takeoffCity, self.takeoffDate, self.takeoffHour,
                             self.landingCity, self.landingDate, self.landingHour,
                             self.carrier, @( self.number ),
                            @( self.price )];
    return description;
}

@end
