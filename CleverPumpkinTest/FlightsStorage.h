//
//  FlightsStorage.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlightData.h"

@protocol FlightsStorageProtocol <NSObject>

@optional
- (void)flightsUpdated:(NSArray*)updatedFlights;
- (void)failedWithError:(NSError*)error;

@end

typedef void (^detailedFlightCompletionHandler_t)(FlightData*);

@interface FlightsStorage : NSObject

@property (nonatomic, weak) id<FlightsStorageProtocol> delegate;
@property (nonatomic, readonly, strong) NSArray *flightsList;

- (NSError*)fetchNewData;
- (NSError*)fetchDataForFlight:(NSUInteger)flightNumber
          withComletionHandler:(detailedFlightCompletionHandler_t)completionHandler;

@end
