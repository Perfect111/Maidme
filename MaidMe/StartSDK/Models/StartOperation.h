//
//  StartOperation.h
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

#import "Start.h"

NS_ASSUME_NONNULL_BEGIN

@class StartAPIClient;
@class StartCard;

@interface StartOperation : NSObject

- (instancetype)initWithAPIClient:(StartAPIClient *)apiClient
                             card:(StartCard *)card
                           amount:(NSInteger)amount
                         currency:(NSString *)currency
                     successBlock:(StartSuccessBlock)successBlock
                       errorBlock:(StartErrorBlock)errorBlock
                      cancelBlock:(StartCancelBlock)cancelBlock NS_DESIGNATED_INITIALIZER;

- (void)perform;

@end

NS_ASSUME_NONNULL_END
