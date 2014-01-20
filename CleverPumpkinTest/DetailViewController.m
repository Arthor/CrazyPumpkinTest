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
    TableViewSections_TakeoffLanding,
    TableViewSections_FlightDuration,
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

#pragma mark - Initialization

- (instancetype)initWithFlightData:(FlightData*)flightData
{
    self = [super init];
    if (self)
    {
        _flightData = flightData;
    }
    return self;
}

#pragma mark - ViewController Lifecycle

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
    if (section == TableViewSections_TakeoffLanding)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableViewSections_NumberOfSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TableViewSections_TakeoffLanding:
            return @"Travel Departure Time";
            break;
            
        case TableViewSections_FlightDuration:
            return @"Flight duration";
            break;
        
        case TableViewSections_Price:
            return @"Price";
            break;
        
        case TableViewSections_Description:
            return @"Description";
            break;
        
        case TableViewSections_Image:
            return @"Image";
            break;
            
        default:
            break;
    }
    return nil;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    };
    
    switch (indexPath.section) {
        case TableViewSections_TakeoffLanding:
        {
            cell = generalCell(kCellIdentifierGeneral);
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"Takeoff Date";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                       self.flightData.takeoffDate,
                                       self.flightData.takeoffHour];
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = @"Landing Date";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                        self.flightData.landingDate,
                                             self.flightData.landingHour];
            }

        }
            break;
            
        case TableViewSections_Price:
        {
            cell = generalCell(kCellIdentifierGeneral);
            cell.textLabel.text = @(self.flightData.price).stringValue;
        }
            break;
            
        case TableViewSections_FlightDuration:
        {
            cell = generalCell(kCellIdentifierGeneral);
            cell.textLabel.text = self.flightData.flightDuration;
        }
            break;
            
        case TableViewSections_Description:
        {
            cell = generalCell(kCellIdentifierDescription);
            cell.textLabel.text = self.flightData.flightDescription;
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

- (void)updateTableViewFromOldData:(FlightData*)oldData toNewData:(FlightData*)newData
{
    NSMutableArray *indexesToUpdate = [NSMutableArray array];
    
    //TODO: It's possible to check for the whole bunch of date, not only image;
    if (![oldData.flightDescription isEqualToString:newData.flightDescription])
    {
        [indexesToUpdate addObject:[NSIndexPath indexPathForRow:0
                                                      inSection:TableViewSections_Description]];
    }
    
    if (![oldData.photoURL isEqual:newData.photoURL])
    {
        [indexesToUpdate addObject:[NSIndexPath indexPathForRow:0
                                                      inSection:TableViewSections_Image]];
    }
    
    if (![indexesToUpdate count])
        return;
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexesToUpdate
                          withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
}

#pragma mark - Setters/Getters
- (void)setFlightData:(FlightData *)newFlightData
{
    FlightData *oldFlightData = _flightData;
    _flightData = newFlightData;
    [self updateTableViewFromOldData:oldFlightData toNewData:newFlightData];
}

@end
