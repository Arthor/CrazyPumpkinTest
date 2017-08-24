//
//  FlightXMLParseOperation.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

@import UIKit;

extern NSString *kFlightXMLParsed;
extern NSString *kFlightDetailedXMLParsed;

extern NSString *kFlightXMLResultKey;

extern NSString *kFlightXMLErrorNotificationName;
extern NSString *kFlightXMLMessageErrorKey;

typedef NS_ENUM(NSUInteger, FlightXMLType)
{
    FlightXMLType_General,
    FlightXMLType_Detail
};

@interface FlightXMLParseOperation : NSOperation

@property (copy, readonly) NSData *flightXMLData;

- (id)initWithData:(NSData *)parseData andXMLType:(FlightXMLType)type;

@end
