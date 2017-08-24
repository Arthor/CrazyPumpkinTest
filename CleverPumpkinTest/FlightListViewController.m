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
#import "CleverPumpkinTest-Swift.h"

static NSString* const kTableViewCellIdentifier = @"tableViewCellIdentifier";

@interface FlightListViewController () <FlightsStorageProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *cachedFlightList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) CGFloat cellHeight;

@end

@implementation FlightListViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed:)];
    self.navigationItem.rightBarButtonItem = sortButton;
    UIBarButtonItem *offlineButton = [[UIBarButtonItem alloc] initWithTitle:@"Offline" style:UIBarButtonItemStylePlain target:self action:@selector(offlineButtonPressed:)];
    self.navigationItem.leftBarButtonItem = offlineButton;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    [self displayActivityIndicator:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.flightsStorage.delegate = self;
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                  animated:YES];
}

#pragma mark - Error Handling

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)displayActivityIndicator:(BOOL)display
{
    if (display)
    {
        self.activityIndicator =
            [[UIActivityIndicatorView alloc]
             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.tableView addSubview:self.activityIndicator];
        //TODO: create offset for iOS7 translucency bar
        self.activityIndicator.center = self.tableView.center;
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    }
}

#pragma mark - FlightsStorageProtocol
- (void)flightsUpdated:(NSArray*)updatedFlights
{
    [self displayActivityIndicator:NO];
    if (!updatedFlights)
        return;

    __weak typeof(self) weakSelf = self;
    NSIndexSet *indexesToRemove = [self.cachedFlightList
                                   indexesOfObjectsPassingTest:^BOOL(id obj,
                                                                     NSUInteger idx,
                                                                     BOOL *stop)
    {
        return ![updatedFlights containsObject:obj];
    }];
    
    NSIndexSet *indexesToAdd = [updatedFlights
                                indexesOfObjectsPassingTest:^BOOL(id obj,
                                                                  NSUInteger idx,
                                                                  BOOL *stop)
    {
        return ![weakSelf.cachedFlightList containsObject:obj];
    }];
    
    NSIndexSet *indexesToUpdate = [self.cachedFlightList
                                   indexesOfObjectsPassingTest:^BOOL(id obj,
                                                                     NSUInteger idx,
                                                                     BOOL *stop)
    {
        if ([updatedFlights containsObject:obj] &&
            ![obj isEqual:updatedFlights[idx]]) {
            return YES;
        }
        return NO;
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:NSIndexSetToNSIndexPathArray(indexesToAdd, 0)
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView deleteRowsAtIndexPaths:NSIndexSetToNSIndexPathArray(indexesToRemove, 0)
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadRowsAtIndexPaths:NSIndexSetToNSIndexPathArray(indexesToUpdate, 0)
                          withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [self displayActivityIndicator:NO];
    [self.tableView reloadData];
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
    [self.flightsStorage fetchDataForFlight:clickedFlight.number
                       withComletionHandler:^(FlightData *newFlightData)
    {
        detailVC.flightData = newFlightData;
        NSLog(@"Detailed info of flight fetched: %@", newFlightData);
    }];
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Handling
- (void)sortButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sort flights" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"By price" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.flightsStorage sortFlightsBy:SortFlightParameter_Price];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"By duration" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.flightsStorage sortFlightsBy:SortFlightParameter_Duration];
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}


- (void)offlineButtonPressed:(id)sender
{
    [NSURLProtocol registerClass:[OfflineURLProtocol class]];
    [self.flightsStorage fetchNewData];
}

@end
