//
//  StartAPIClientRequest.h
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol StartAPIClientRequest <NSObject>

@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSDictionary *params;
@property (nonatomic, assign, readonly) BOOL shouldRetry;
@property (nonatomic, assign, readonly) NSTimeInterval retryInterval;
@property (nonatomic, strong, readonly) id response;

- (void)registerPerforming;
- (BOOL)processResponse:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
