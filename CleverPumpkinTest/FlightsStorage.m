//
//  FlightsStorage.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightsStorage.h"

#import "FlightXMLParseOperation.h"
#import "NetworkLoader.h"

@interface FlightsStorage()<NetworkLoaderProtocol>

@property (nonatomic, strong) NSArray *oldFlightsList;
@property (nonatomic, strong) NSArray *internalFlightsList;
@property (nonatomic, strong) NetworkLoader *networkLoader;
@property (nonatomic, strong) NSTimer *updateTimer;

@end

@implementation FlightsStorage

- (id)init
{
    if (self = [super init])
    {
        _internalFlightsList = [[NSArray alloc] init];
        _networkLoader = [[NetworkLoader alloc] init];
        _networkLoader.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addParsedFlight:)
                                                     name:kFlightXMLParsed
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(parserError:)
                                                     name:kFlightXMLErrorNotificationName
                                                   object:nil];
        [self.networkLoader fetchNewData];
    }
    
    return self;
}

- (NSArray *)flightsList
{
    return [self.internalFlightsList copy];
}

#pragma mark - NSNotification Callbacks
- (void)addParsedFlight:(NSNotification*)notification
{
    assert([NSThread isMainThread]);
    NSArray *parsedFlights = [[notification userInfo] valueForKey:kFlightXMLResultKey];
    if (![parsedFlights count])
        return;

    //TODO: we don't store previous flights as it's not stated in the specs
    self.internalFlightsList = parsedFlights;
    if ([self.delegate respondsToSelector:@selector(flightsUpdated:)])
        [self.delegate flightsUpdated:self.internalFlightsList];
}

- (void)parserError:(NSNotification*)notification
{
    assert([NSThread isMainThread]);
    [self handlerError:[notification valueForKey:kFlightXMLMessageErrorKey]];
}

- (void)handlerError:(NSError*)error
{
    if ([self.delegate respondsToSelector:@selector(failedWithError:)])
        [self.delegate failedWithError:error];
}

- (NSError *)fetchNewData
{
    NSError *error = [self.networkLoader fetchNewData];
    return error;
}

- (void)fetchNewDataTimerFired:(id)sender
{
    
}

- (void)setUpTimer:(CGFloat)updateInterval
{
    [self.updateTimer invalidate];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                                        target:self
                                                      selector:@selector(fetchNewDataTimerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
}

#pragma mark - NetworkLoaderProtocol
- (void)fetchedDataWithError:(NSError *)error
{
    if (!error)
    {
        
    }
    else
        [self handlerError:error];
}

@end
