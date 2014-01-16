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

@interface NetworkLoader()

@property (nonatomic, strong) NSTimer *updateTimer;
//@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSOperationQueue *connectionQueue;
@property (nonatomic, strong) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSData *xmlData;
@property (nonatomic) BOOL isLoading;

@end


@implementation NetworkLoader

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)fetchNewData
{
    [self setUpTimerWithInterval:kUpdateInterval];
    [self.updateTimer fire];
}

- (void)requestNewData
{
    if (self.isLoading)
        return;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kCleverPumpkinURL]
                                             cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                         timeoutInterval:kTimeoutInterval];
    
    __weak typeof(self) weakSelf = self;
    void(^completionHandler)(NSURLResponse *, NSData *, NSError *error) =
        ^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError)
            [self handleError:connectionError];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ((([httpResponse statusCode]/100) == 2) &&
            [[response MIMEType] isEqual:@"application/xml"])
        {
            [self.parseQueue cancelAllOperations];
            FlightXMLParseOperation *parseOperation =
                [[FlightXMLParseOperation alloc] initWithData:data];
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
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completionHandler];
}

#pragma mark - Utility
- (void)setUpTimerWithInterval:(CGFloat)interval
{
    [self.updateTimer invalidate];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval
                                                        target:self
                                                      selector:@selector(requestNewData)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)handleError:(NSError*)connectionError
{
    
}


@end
