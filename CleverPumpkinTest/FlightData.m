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
    void(^completionHandler)(NSURLResponse *, NSData *, NSError *error) =
    ^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        UIImage *image = [UIImage imageWithData:data];
        if (image)
            weakSelf.image = image;
        isLoading = NO;
    };

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completionHandler];
    isLoading = YES;
}

@end
