//
//  NSString+Start.h
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Start)

- (NSString *)startStringByRemovingCharactersInSet:(NSCharacterSet *)set;

@end

NS_ASSUME_NONNULL_END
