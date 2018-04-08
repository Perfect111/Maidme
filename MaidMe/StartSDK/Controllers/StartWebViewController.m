//
//  StartWebViewController.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartWebViewController.h"

@implementation StartWebViewController {
    NSURL *_url;
    __weak UIWebView *_webView;
}

#pragma mark - Private methods

- (void)initWebView {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:webView];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                      options:(NSLayoutFormatOptions) 0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(webView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                                      options:(NSLayoutFormatOptions) 0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(webView)]];

    _webView = webView;
}

#pragma mark - UIViewController methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    // overriding designated initializer of superclass
    return [self initWithURL:(NSURL *_Nonnull) [NSURL URLWithString:@""]];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    // overriding designated initializer of superclass
    return [self initWithURL:(NSURL *_Nonnull) [NSURL URLWithString:@""]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

#pragma mark - Interface methods

- (instancetype)initWithURL:(NSURL *)url {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _url = url;
    }
    return self;
}

@end
