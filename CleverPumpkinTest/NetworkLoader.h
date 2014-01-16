//
//  NetworkLoader.h
//  CleverPumpkinTest
//
//  Created by Artem Abramov on 1/16/14.
//  Copyright (c) 2014 Artem Abramov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NetworkLoaderErrorCodes)
{
    NetworkLoaderError_Success,
    NetworkLoaderError_ConnectionIsAlreadyRunning,
    NetworkLoaderError_IncompleteOrIncorrectJSON,
    NetworkLoaderError_NumberOfErrors
};

@protocol NetworkLoaderProtocol <NSObject>

- (void)update;
- (void)updateItemsWithIndexes:(NSIndexSet *)indexes;
- (void)removeItemsWithIndexes:(NSIndexSet *)indexes;
- (void)insertItemsAtIndexes:(NSIndexSet *)indexes;

@end

@interface NetworkLoader : NSObject

@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, weak) id<NetworkLoaderProtocol> delegate;

- (void)fetchNewData;

@end
