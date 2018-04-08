//
//  StartTokenRequest.m
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartTokenRequest.h"
#import "StartCard.h"
#import "StartTokenEntity.h"
#import "StartAPIClient.h"

@implementation StartTokenRequest {
    NSDictionary *_params;
    StartTokenEntity *_token;
    NSInteger _attemptsCount;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithCard:[[StartCard alloc] init]];
}

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return @"POST";
}

- (NSString *)path {
    return @"tokens";
}

- (NSDictionary *)params {
    return _params;
}

- (BOOL)shouldRetry {
    return _attemptsCount > 0;
}

- (NSTimeInterval)retryInterval {
    return StartAPIClientRetryAttemptsInterval;
}

- (id)response {
    return _token;
}

- (void)registerPerforming {
    _attemptsCount--;
}

- (BOOL)processResponse:(NSDictionary *)response {
    @try {
        _token = [[StartTokenEntity alloc] initWithDictionary:response];
        return YES;
    }
    @catch (NSException *exception) {
        if (exception.name != StartAPIClientInvalidDataExceptionName) {
            [exception raise];
        }
        return NO;
    }
}

#pragma mark - Interface methods

- (instancetype)initWithCard:(StartCard *)card {
    self = [super init];
    if (self) {
        _attemptsCount = StartAPIClientRetryAttemptsCount;
        _params = @{
                @"name": card.cardholder,
                @"number": card.number,
                @"cvc": card.cvc,
                @"exp_month": @(card.expirationMonth),
                @"exp_year": @(card.expirationYear)
        };
    }
    return self;
}

@end
