//
//  FlightXMLParseOperation.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kFlightXMLParsed;
extern NSString *kFlightXMLResultKey;

extern NSString *kFlightXMLErrorNotificationName;
extern NSString *kFlightXMLMessageErrorKey;

@interface FlightXMLParseOperation : NSOperation

@property (copy, readonly) NSData *flightXMLData;

- (id)initWithData:(NSData *)parseData;

@end
