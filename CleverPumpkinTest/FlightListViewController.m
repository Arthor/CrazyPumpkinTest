//
//  FlightListViewController.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/19/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightListViewController.h"

#import "FlightXMLParseOperation.h"
#import "FlightsStorage.h"
#import "FlightInfoCell.h"
#import "DetailViewController.h"

static NSString* const kTableViewCellIdentifier = @"tableViewCellIdentifier";


@interface FlightListViewController ()<FlightsStorageProtocol,
                                       UITableViewDataSource,
                                       UITableViewDelegate>

@property (nonatomic, strong) NSArray *cachedFlightList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) CGFloat cellHeight;

@end

@implementation FlightListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FlightInfoCell" bundle:nil]
         forCellReuseIdentifier:kTableViewCellIdentifier];
    FlightInfoCell *cellToCalcHeight = [[[NSBundle mainBundle] loadNibNamed:@"FlightInfoCell"
                                                                      owner:self
                                                                    options:nil] firstObject];
    self.tableView.rowHeight = CGRectGetHeight(cellToCalcHeight.frame);
    [self.view addSubview:self.tableView];
    self.title = @"Flight List";
    [self.flightsStorage fetchNewData];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.flightsStorage.delegate = self;
}

- (void)handleError:(NSError *)error
{
    
    NSString *errorMessage = [error localizedDescription];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - FlightsStorageProtocol
- (void)flightsUpdated:(NSArray*)updatedFlights
{
    
    if (!updatedFlights)
        return;
    

    __weak typeof(self) weakSelf = self;
    NSIndexSet *indexesToRemove = [NSIndexSet indexSet];
    indexesToRemove = [self.cachedFlightList indexesOfObjectsPassingTest:^BOOL(id obj,
                                                                            NSUInteger idx,
                                                                            BOOL *stop)
    {
        return ![updatedFlights containsObject:obj];
    }];
    
    NSIndexSet *indexesToAdd = [NSIndexSet indexSet];
    indexesToAdd = [updatedFlights indexesOfObjectsPassingTest:^BOOL(id obj,
                                                                    NSUInteger idx,
                                                                    BOOL *stop)
    {
        return ![weakSelf.cachedFlightList containsObject:obj];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:NSIndexSetToNSIndexPathArray(indexesToAdd, 0)
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView deleteRowsAtIndexPaths:NSIndexSetToNSIndexPathArray(indexesToRemove, 0)
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    self.cachedFlightList = updatedFlights;
}

static inline NSArray* NSIndexSetToNSIndexPathArray(NSIndexSet *indexes, NSUInteger section)
{
    if (!indexes)
        return nil;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:indexes.count];
    NSUInteger index = [indexes firstIndex];
    while (index != NSNotFound) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:section]];
        index = [indexes indexGreaterThanIndex:index];
    }
    return [indexPaths copy];
}

- (void)failedWithError:(NSError*)error
{
    [self handleError:error];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.flightsStorage.flightsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlightInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier
                                                           forIndexPath:indexPath];
    FlightData *currentFlight = self.flightsStorage.flightsList[indexPath.row];
    [cell configureForFlight:currentFlight];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlightData *clickedFlight = self.flightsStorage.flightsList[indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithFlightData:clickedFlight];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
