//
//  FlightData.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightData : NSObject

@property(nonatomic) NSTimeInterval duration;
@property(nonatomic, strong) NSDate *takeoffDate;
@property(nonatomic, strong) NSDate *landingDate;

@property(nonatomic, strong) NSString *carrier;
@property(nonatomic) NSUInteger number;
@property(nonatomic) NSUInteger price;

@end
