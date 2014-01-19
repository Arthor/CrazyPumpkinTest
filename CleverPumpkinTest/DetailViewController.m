//
//  DetailViewController.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "DetailViewController.h"

#import "FlightData.h"

typedef NS_ENUM(NSUInteger, TableViewSections)
{
    TableViewSections_Takeoff,
    TableViewSections_Landing,
    TableViewSections_Price,
    TableViewSections_Description,
    TableViewSections_Image,
    TableViewSections_NumberOfSection
};

static NSString* const kCellIdentifierGeneral = @"kCellIdentifierGeneral";
static NSString* const kCellIdentifierDescription = @"kCellIdentifierDescription";
static NSString* const kCellIdentifierImage = @"kCellIdentifierImage";

@interface DetailViewController ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DetailViewController

- (instancetype)initWithFlightData:(FlightData*)flightData
{
    self = [super init];
    if (self)
    {
        _flightData = flightData;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.title = [NSString stringWithFormat:@"%@ %@",
                  self.flightData.carrier,
                  @(self.flightData.number).stringValue];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableViewSections_NumberOfSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block UITableViewCell *cell = nil;
    
    UITableViewCell*(^generalCell)(NSString*) = ^UITableViewCell*(NSString* identifier){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:identifier];
        return cell;
    };
    
    switch (indexPath.section) {
        case TableViewSections_Takeoff:
        {
            cell = generalCell(kCellIdentifierGeneral);
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                                   self.flightData.takeoffDate,
                                   self.flightData.takeoffHour];
        }
            break;
            
        case TableViewSections_Landing:
        {
            cell = generalCell(kCellIdentifierGeneral);
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                                   self.flightData.landingDate,
                                   self.flightData.landingHour];
        }
            break;
            
        case TableViewSections_Price:
        {
            cell = generalCell(kCellIdentifierGeneral);
            cell.textLabel.text = @(self.flightData.price).stringValue;
        }
            break;
            
        case TableViewSections_Description:
        {
            cell = generalCell(kCellIdentifierDescription);
            cell.textLabel.text = self.flightData.description;
        }
            break;
        
        case TableViewSections_Image:
        {
            cell = generalCell(kCellIdentifierImage);
            
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
