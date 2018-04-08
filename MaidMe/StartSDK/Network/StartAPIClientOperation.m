//
//  StartAPIClientOperation.m
//  StartSDK
//
//  Created by Viktor on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartAPIClientOperation.h"
#import "StartAPIClientRequest.h"
#import "NSBundle+Start.h"

@implementation StartAPIClientOperation {
    NSString *_base;
    NSString *_authorization;

    NSURLSession *_session;
    NSURLRequest *_urlRequest;

    id <StartAPIClientRequest> _request;

    StartAPIClientSuccessBlock _successBlock;
    StartAPIClientErrorBlock _errorBlock;
}

#pragma mark - Private methods

- (BOOL)formURLRequest {
    NSURL *url = [NSURL URLWithString:[_base stringByAppendingString:_request.path]];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:_request.method];
    [urlRequest addValue:_authorization forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:[NSBundle bundleForClass:[self class]].startVersion forHTTPHeaderField:@"StartiOS"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if (![_request.method isEqualToString:@"GET"] && _request.params) {
        NSData *jsonData;
        @try {
            jsonData = [NSJSONSerialization dataWithJSONObject:_request.params options:(NSJSONWritingOptions) 0 error:nil];
        }
        @catch (NSException *) {
            _errorBlock([NSError errorWithDomain:StartAPIClientError code:StartAPIClientErrorCodeCantFormJSON userInfo:nil]);
            return NO;
        }
        [urlRequest setHTTPBody:jsonData];
    }

    _urlRequest = urlRequest;

    return YES;
}

- (void)startDataTask {
    [_request registerPerforming];

    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:_urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleResponse:response data:data error:error];
    }];
    [dataTask resume];
}

- (void)handleResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {

    if (!error) {
        if (data) {

            NSDictionary *userInfo;
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (responseString) {
                userInfo = @{
                        StartAPIClientErrorKeyResponse: responseString
                };
            }

            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) 0 error:nil];
            
            if ([responseJSON isKindOfClass:[NSDictionary class]]) {
                if ([response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse *)response).statusCode / 100 == 2) {
                    if ([_request processResponse:responseJSON]) {
                        _successBlock();
                    }
                    else {
                        error = [NSError errorWithDomain:StartAPIClientError code:StartAPIClientErrorCodeInvalidResponse userInfo:userInfo];
                    }
                }
                else {
                    if ([responseJSON[@"error"][@"type"] isEqualToString:@"authentication"]) {
                        error = [NSError errorWithDomain:StartAPIClientError code:StartAPIClientErrorCodeInvalidAPIKey userInfo:userInfo];
                    }
                    else {
                        error = [NSError errorWithDomain:StartAPIClientError code:StartAPIClientErrorCodeServerError userInfo:userInfo];
                    }
                };
            }
            else {
                error = [NSError errorWithDomain:StartAPIClientError code:StartAPIClientErrorCodeInvalidResponse userInfo:userInfo];
            }
        }
        else {
            error = [NSError errorWithDomain:StartAPIClientError code:StartAPIClientErrorCodeInvalidResponse userInfo:nil];
        }
    }
    if (error) {
        if ((error.domain != StartAPIClientError || error.code != StartAPIClientErrorCodeInvalidAPIKey) && _request.shouldRetry) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (NSEC_PER_SEC * _request.retryInterval)), dispatch_get_main_queue(), ^{
                if (self->_request.shouldRetry) {
                    [self startDataTask];
                }
            });
        }
        else {
            _errorBlock(error);
        }
    }
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithBase:@""
                authorization:@""
                      session:NSURLSession.sharedSession
                      request:(id <StartAPIClientRequest>) @""
                 successBlock:^{}
                   errorBlock:^(NSError *error) {}];
}

#pragma mark - Interface methods

- (instancetype)initWithBase:(NSString *)base
               authorization:(NSString *)authorization
                     session:(NSURLSession *)session
                     request:(id <StartAPIClientRequest>)request
                successBlock:(StartAPIClientSuccessBlock)successBlock
                  errorBlock:(StartAPIClientErrorBlock)errorBlock {

    self = [super init];
    if (self) {
        _base = base.copy;
        _authorization = authorization.copy;

        _session = session;
        _request = request;

        _successBlock = [successBlock copy];
        _errorBlock = [errorBlock copy];
    }
    return self;
}

- (void)perform {
    if (![self formURLRequest]) {
        return;
    }

    [self startDataTask];
}

@end
