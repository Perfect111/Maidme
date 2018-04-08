//
//  NSBundle+Start.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "NSBundle+Start.h"
#import "Start.h"

@implementation NSBundle (Start)

#pragma mark - Interface methods

- (NSString *)startVersion {
    NSDictionary *infoDictionary = self.infoDictionary;
    return [NSString stringWithFormat:@"%@.%@", infoDictionary[@"CFBundleShortVersionString"], infoDictionary[@"CFBundleVersion"]];
}

@end
