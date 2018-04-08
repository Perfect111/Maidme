//
//  NSDate+Start.m
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "NSDate+Start.h"

@implementation NSDate (Start)

#pragma mark - Interface methods

- (NSInteger)startYear {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar component:NSCalendarUnitYear fromDate:self];
}

- (NSInteger)startMonth {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar component:NSCalendarUnitMonth fromDate:self];
}

@end
