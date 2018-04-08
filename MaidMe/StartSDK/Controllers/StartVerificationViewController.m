//
//  StartVerificationViewController.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartVerificationViewController.h"
#import "StartTokenEntity.h"
#import "StartWebViewController.h"

@implementation StartVerificationViewController {
    StartVerificationViewControllerCancelBlock _cancelBlock;
}

#pragma mark - Private methods

- (void)onCancel:(UIButton *)button {
    _cancelBlock();
}

#pragma mark - Interface methods

- (instancetype)initWithToken:(StartTokenEntity *)token
                         base:(NSString *)base
                  cancelBlock:(StartVerificationViewControllerCancelBlock)cancelBlock {

    NSURL *url = [NSURL URLWithString:[base stringByAppendingFormat:@"tokens/%@/verification/verify", token.tokenId]];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];

    StartWebViewController *webViewController = [[StartWebViewController alloc] initWithURL:url];
    webViewController.navigationItem.rightBarButtonItem = cancelButton;

    self = [super initWithRootViewController:webViewController];
    if (self) {
        _cancelBlock = [cancelBlock copy];
    }
    return self;
}

@end
