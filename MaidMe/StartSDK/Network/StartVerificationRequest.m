//
//  StartVerificationRequest.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartVerificationRequest.h"
#import "StartTokenEntity.h"
#import "StartVerification.h"
#import "StartAPIClient.h"

@implementation StartVerificationRequest {
    NSString *_method;
    NSString *_path;
    NSDictionary *_params;
    StartVerification *_verification;
    NSInteger _attemptsCount;
    BOOL _isCancelled;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithToken:[[StartTokenEntity alloc] init] amount:0 currency:@"" method:@""];
}

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return _method;
}

- (NSString *)path {
    return _path;
}

- (NSDictionary *)params {
    return [_method isEqualToString:@"POST"] ? _params : @{};
}

- (BOOL)shouldRetry {
    if ([_method isEqualToString:@"POST"]) {
        return _attemptsCount > 0;
    }
    else {
        return !_isCancelled && !_verification.isFinalized;
    }
}

- (NSTimeInterval)retryInterval {
    return StartAPIClientRetryAttemptsInterval;
}

- (id)response {
    return _verification;
}

- (void)registerPerforming {
    _attemptsCount--;
}

- (BOOL)processResponse:(NSDictionary *)response {
    @try {
        _verification = [[StartVerification alloc] initWithDictionary:response];
        return ![_method isEqualToString:@"GET"] || _verification.isFinalized;
    }
    @catch (NSException *exception) {
        if (exception.name != StartAPIClientInvalidDataExceptionName) {
            [exception raise];
        }
        return NO;
    }
}

#pragma mark - Interface methods

- (instancetype)initWithToken:(StartTokenEntity *)token
                       amount:(NSInteger)amount
                     currency:(NSString *)currency
                       method:(NSString *)method {
    self = [super init];
    if (self) {
        _attemptsCount = StartAPIClientRetryAttemptsCount;
        _method = method.copy;
        _path = [NSString stringWithFormat:@"tokens/%@/verification", token.tokenId];
        _params = @{
                @"amount": @(amount),
                @"currency": currency
        };
    }
    return self;
}

- (void)cancel {
    _isCancelled = YES;
}

@end
