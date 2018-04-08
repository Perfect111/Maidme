//
//  MAKMonthPicker.h
//  MonthPicker
//
//  Created by Denis Chaschin on 07.11.14.
//  Copyright (c) 2014 diniska. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAKMonthPicker;

@protocol MAKMonthPickerDelegate <NSObject>
- (void)monthPickerDidChangeDate:(MAKMonthPicker *)picker;
@end

typedef NS_OPTIONS(NSInteger, MAKMonthPickerFormat) {
    MAKMonthPickerFormatMonth  = 1,
    MAKMonthPickerFormatYear   = 1 << 1
};

@interface MAKMonthPicker : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) id<MAKMonthPickerDelegate> monthPickerDelegate;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) MAKMonthPickerFormat format;
/**
 * @param monthFormat use %c for month code and %n form month name. 
 *                    By default monthFormat = "%n %c"
 */
@property (strong, nonatomic) NSString *monthFormat;
/**
 * @param yearRange from now day - 10 years to now day + 10 years
 */
@property (assign, nonatomic) NSRange yearRange;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;
@end
