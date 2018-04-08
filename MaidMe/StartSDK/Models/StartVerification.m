//
//  StartVerification.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartVerification.h"
#import "NSNumber+Start.h"
#import "StartAPIClient.h"

@implementation StartVerification

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithDictionary:@{}];
}

#pragma mark - Interface methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (![dictionary[@"enrolled"] isKindOfClass:[NSNumber class]] || ![dictionary[@"enrolled"] startIsBOOL]) {
            [[NSException exceptionWithName:StartAPIClientInvalidDataExceptionName reason:nil userInfo:nil] raise];
        }
        _isEnrolled = [dictionary[@"enrolled"] boolValue];

        if (![dictionary[@"finalized"] isKindOfClass:[NSNumber class]] || ![dictionary[@"finalized"] startIsBOOL]) {
            [[NSException exceptionWithName:StartAPIClientInvalidDataExceptionName reason:nil userInfo:nil] raise];
        }
        _isFinalized = [dictionary[@"finalized"] boolValue];
    }
    return self;
}

@end
