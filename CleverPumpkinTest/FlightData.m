//
//  FlightData.m
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import "FlightData.h"

@implementation FlightData

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"Flight from %@ at %@ %@ "
                             "to %@ at %@ %@ by %@ %@. "
                             "Price: %@", self.takeoffCity, self.takeoffDate, self.takeoffHour,
                             self.landingCity, self.landingDate, self.landingHour,
                             self.carrier, @( self.number ),
                            @( self.price )];
    return description;
}

- (void)setPhotoURL:(NSURL *)photoURL
{
    _photoURL = photoURL;
    static BOOL isLoading = NO;
    if (isLoading)
        return;
    NSURLRequest *request = [NSURLRequest requestWithURL:_photoURL];
    
    __weak typeof(self) weakSelf = self;
    void(^completionHandler)(NSData *, NSURLResponse *, NSError *) =
    ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIImage *image = [UIImage imageWithData:data];
            if (image)
                weakSelf.image = image;
            isLoading = NO;
        });
    };

    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:completionHandler] resume];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    isLoading = YES;
}

@end
