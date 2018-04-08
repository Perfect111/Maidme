//
//  NSNumber+Start.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "NSNumber+Start.h"

@implementation NSNumber (Start)

#pragma mark - Interface methods

- (BOOL)startIsBOOL {
    return [@(self.boolValue) isEqualToNumber:self];
}

@end
