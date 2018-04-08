//
//  StartAPIClientOperation.h
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

#import "StartAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@protocol StartAPIClientRequest;

@interface StartAPIClientOperation : NSObject

- (instancetype)initWithBase:(NSString *)base
               authorization:(NSString *)authorization
                     session:(NSURLSession *)session
                     request:(id <StartAPIClientRequest>)request
                successBlock:(StartAPIClientSuccessBlock)successBlock
                  errorBlock:(StartAPIClientErrorBlock)errorBlock NS_DESIGNATED_INITIALIZER;

- (void)perform;

@end

NS_ASSUME_NONNULL_END
