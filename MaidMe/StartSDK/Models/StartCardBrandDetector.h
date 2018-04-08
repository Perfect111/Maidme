//
//  StartCardBrandDetector.h
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

@class StartCard;

NS_ASSUME_NONNULL_BEGIN

@interface StartCardBrandDetector : NSObject

- (instancetype)initWithPrefixes:(NSArray *)prefixes lengths:(NSArray *)lengths NS_DESIGNATED_INITIALIZER;
- (BOOL)isContainingCard:(StartCard *)card;

@end

NS_ASSUME_NONNULL_END
