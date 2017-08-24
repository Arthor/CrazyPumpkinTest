//
//  NetworkLoader.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "NetworkLoader.h"
#import "FlightXMLParseOperation.h"

const CGFloat kUpdateInterval = 30.0f;
const CGFloat kTimeoutInterval = 30.0f;
NSString* const kCleverPumpkinURL = @"http://cleverpumpkin.ru/test/flights0541.xml";
NSString* const kCleverPumpkinDetailFlightURL = @"http://cleverpumpkin.ru/test/flights/";


@interface NetworkLoader()
{
    NSUInteger _flightNumber;
}

@property (nonatomic, strong) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSData *xmlData;
@property (nonatomic) BOOL isLoading;

@end


@implementation NetworkLoader

- (void)cancelLoading
{
    [self.parseQueue cancelAllOperations];
    self.parseQueue = nil;
}

- (NSError*)fetchDataForFlight:(NSUInteger)flightNumber
{
    _flightNumber = flightNumber;
    NSError *error = [self fetchNewDataOfType:FlightXMLType_Detail];
    return error;
}

- (NSError*)fetchNewData
{
    NSError *error = [self fetchNewDataOfType:FlightXMLType_General];
    return error;
}

- (NSError*)fetchNewDataOfType:(FlightXMLType)type
{
    NSError *error = nil;
    if (self.isLoading)
        return [NSError errorWithDomain:@"HTTP error"
                                   code:NetworkLoaderError_ConnectionIsAlreadyRunning
                               userInfo:nil];
    NSURL *url = nil;
    if (type == FlightXMLType_Detail)
    {
        url = [NSURL URLWithString:kCleverPumpkinDetailFlightURL];
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%ld.xml", _flightNumber]];
    }
    else if (FlightXMLType_General == type)
    {
        url = [NSURL URLWithString:kCleverPumpkinURL];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                         timeoutInterval:kTimeoutInterval];
    
    __weak typeof(self) weakSelf = self;
    void(^completionHandler)(NSData *, NSURLResponse *, NSError *) =
    ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        if (error)
            [self handleError:error];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ((([httpResponse statusCode]/100) == 2))
        {
            [self.parseQueue cancelAllOperations];
            FlightXMLParseOperation *parseOperation =
                [[FlightXMLParseOperation alloc] initWithData:data andXMLType:type];
            [self.parseQueue addOperation:parseOperation];
        }
        else
        {
            NSString *errorString = @"HTTP Error";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
            NSError *reportError = [NSError errorWithDomain:@"HTTP"
                                                       code:[httpResponse statusCode]
                                                   userInfo:userInfo];
            [self handleError:reportError];
        }
        weakSelf.isLoading = NO;
    };
    self.parseQueue = [NSOperationQueue new];
    NSURLSessionDataTask *task =  [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return error;
}

#pragma mark - Utility

- (void)handleError:(NSError*)connectionError
{
    if ([self.delegate respondsToSelector:@selector(fetchedDataWithError:)])
        [self.delegate fetchedDataWithError:connectionError];
}

@end
