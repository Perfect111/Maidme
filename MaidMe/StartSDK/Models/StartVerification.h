//
//  StartVerification.h
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface StartVerification : NSObject

@property (nonatomic, assign, readonly) BOOL isEnrolled;
@property (nonatomic, assign, readonly) BOOL isFinalized;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
