//
//  StartVerificationRequest.h
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

#import "StartAPIClientRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class StartTokenEntity;

@interface StartVerificationRequest : NSObject <StartAPIClientRequest>

- (instancetype)initWithToken:(StartTokenEntity *)token
                       amount:(NSInteger)amount
                     currency:(NSString *)currency
                       method:(NSString *)method NS_DESIGNATED_INITIALIZER;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
