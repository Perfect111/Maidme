//
//  StartToken.h
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** Token object received from API. Uniquely represents charge operation of the card. */
@protocol StartToken <NSObject>

/** Token ID, uniquely represents StartToken. Can be used for API calls that require a card charge operation. */
@property (nonatomic, copy, readonly) NSString *tokenId;

@end

NS_ASSUME_NONNULL_END
