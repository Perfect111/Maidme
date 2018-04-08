//
//  UIViewController+Start.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "UIViewController+Start.h"

@implementation UIViewController (Start)

#pragma mark - Interface methods

- (UIViewController *)topPresentedViewController {
    return self.presentedViewController ? self.presentedViewController.topPresentedViewController : self;
}

@end
