//
//  FlightInfoCell.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightData;

@interface FlightInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *landingDate;
@property (weak, nonatomic) IBOutlet UILabel *landingTime;
@property (weak, nonatomic) IBOutlet UILabel *takeoffDate;
@property (weak, nonatomic) IBOutlet UILabel *takeoffTime;
@property (weak, nonatomic) IBOutlet UILabel *carrier;
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *price;

- (void)configureForFlight:(FlightData*)flightData;

@end
