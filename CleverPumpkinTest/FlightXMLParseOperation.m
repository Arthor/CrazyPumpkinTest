//
//  FlightXMLParseOperation.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightXMLParseOperation.h"
#import "FlightData.h"

NSString *kFlightXMLParsed = @"kFlightXMLParsed";
NSString *kFlightXMLResultKey = @"kFlightXMLResultKey";

NSString *kFlightXMLErrorNotificationName = @"kFlightXMLErrorNotificationName";
NSString *kFlightXMLMessageErrorKey = @"kFlightXMLErrorNotificationName";

static const NSUInteger kMaximumFlightsToParse = 50;
static NSUInteger const kSizeOFfFlightBatch = 10;

static NSString* const kElementNameTrip = @"trip";
static NSString* const kElementNameTakeoff = @"takeoff";
static NSString* const kElementNameLanding = @"landing";
static NSString* const kElementNameFlight = @"flight";
static NSString* const kElementNamePrice = @"price";
static NSString* const kElementNameResult = @"result";


static NSString* const kAttributeNameTripDuration = @"duration";
static NSString* const kAttributeNameTripDate = @"date";
static NSString* const kAttributeNameTripTime = @"time";
static NSString* const kAttributeNameTripCity = @"city";
static NSString* const kAttributeNameTripNumber = @"number";
static NSString* const kAttributeNameTripEq = @"eq";

@interface FlightXMLParseOperation()<NSXMLParserDelegate>

@property (nonatomic, strong) FlightData *currentFlight;
@property (nonatomic, strong) NSMutableArray *currentParseBatch;
@property (nonatomic, strong) NSMutableString *currentParsedCharacterData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation FlightXMLParseOperation
{
    BOOL _accumulatingParsedCharacterData;
    BOOL _didAbortParsing;
    NSUInteger _parsedFlightsCounter;
}

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self)
    {
        _flightXMLData = [parseData copy];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU_POSIX"]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        
        _currentParseBatch = [[NSMutableArray alloc] init];
        _currentParsedCharacterData = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)notifyAboutParsedXML:(NSArray *)flightsXML
{
    
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kFlightXMLParsed
                                                        object:self
                                                      userInfo:@{kFlightXMLParsed: flightsXML}];
}

#pragma mark - NSOperation

- (void)main
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.flightXMLData];
    parser.delegate = self;
    [parser parse];
    
    if (self.currentParseBatch.count)
        [self performSelectorOnMainThread:@selector(notifyAboutParsedXML:)
                               withObject:self.currentParseBatch
                            waitUntilDone:NO];
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName
         attributes:(NSDictionary *)attributeDict
{
    NSLog(@"Parser started element: %@\nattributes: %@",
          elementName, attributeDict);
    if (_parsedFlightsCounter >= kMaximumFlightsToParse)
    {
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kElementNameTrip])
    {
        self.currentFlight = [[FlightData alloc] init];
        NSString *flightDuration = attributeDict[kAttributeNameTripDuration];
        NSLog(@"Flight duration: %@", flightDuration);
        
    }
    else if ([elementName isEqualToString:kElementNameFlight])
    {
        
    }
    else if ([elementName isEqualToString:kElementNamePrice])
    {
        //Begin accumulating data between tags
        _accumulatingParsedCharacterData = YES;
        [self.currentParsedCharacterData setString:@""];
    }
    
}

- (void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
{
    NSLog(@"Parser did end element:%@\n", elementName);
    
    if ([elementName isEqualToString:kElementNameTrip])
    {
        [self.currentParseBatch addObject:self.currentFlight];
        _parsedFlightsCounter++;
        if ([self.currentParseBatch count] >= kSizeOFfFlightBatch)
        {
            [self performSelectorOnMainThread:@selector(notifyAboutParsedXML:)
                                   withObject:self.currentParseBatch
                                waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    }
    
    //parse price
    if ([elementName isEqualToString:kElementNamePrice] && self.currentFlight )
    {
        self.currentFlight.price = [self.currentParsedCharacterData integerValue];
    }
    
    //result: EOF
    if ([elementName isEqualToString:kElementNameResult])
    {
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    
    _accumulatingParsedCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_accumulatingParsedCharacterData)
    {
        [self.currentParsedCharacterData appendString:string];
        NSLog(@"Characters found: %@", string);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !_didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handleError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

#pragma mark - ErrorHandling

- (void)handleError:(NSError *)error
{
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kFlightXMLErrorNotificationName
                                                        object:self
                                                      userInfo:@{kFlightXMLMessageErrorKey:error }];
}


@end
