//
//  FlightData.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightData : NSObject

@property(nonatomic, strong) NSString *flightDuration;
@property(nonatomic, strong) NSString *takeoffDate;
@property(nonatomic, strong) NSString *takeoffHour;
@property(nonatomic, strong) NSString *landingDate;
@property(nonatomic, strong) NSString *landingHour;
@property(nonatomic, strong) NSString *takeoffCity;
@property(nonatomic, strong) NSString *landingCity;

@property(nonatomic, strong) NSString *carrier;
@property(nonatomic) NSUInteger number;
@property(nonatomic) NSUInteger price;

//Detail Info
@property(nonatomic, strong) NSString *flightDescription;
@property(nonatomic, strong) NSURL *photoURL;

@end
