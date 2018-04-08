//
//  StartAPIClient.m
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartAPIClient.h"
#import "StartAPIClientRequest.h"
#import "StartAPIClientOperation.h"

NSString *const StartAPIClientInvalidDataExceptionName = @"StartAPIClientInvalidDataExceptionName";
NSErrorDomain const StartAPIClientError = @"StartAPIClientError";
NSErrorDomain const StartAPIClientErrorKeyResponse = @"StartAPIClientErrorKeyResponse";
NSInteger const StartAPIClientRetryAttemptsCount = 3;
NSTimeInterval const StartAPIClientRetryAttemptsInterval = 5.0;

@implementation StartAPIClient {
    NSString *_authorization;
    NSURLSession *_session;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithBase:@"" apiKey:@""];
}

#pragma mark - Interface methods

- (instancetype)initWithBase:(NSString *)base apiKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        _base = base.copy;

        NSString *base64Key = [[apiKey dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:(NSDataBase64EncodingOptions) 0];
        _authorization = [@"Basic " stringByAppendingString:base64Key];

        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
                                                 delegate:nil
                                            delegateQueue:NSOperationQueue.mainQueue];
    }
    return self;
}

- (void)performRequest:(id <StartAPIClientRequest>)request
          successBlock:(StartAPIClientSuccessBlock)successBlock
            errorBlock:(StartAPIClientErrorBlock)errorBlock {

    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:_base
                                                                         authorization:_authorization
                                                                               session:_session
                                                                               request:request
                                                                          successBlock:successBlock
                                                                            errorBlock:errorBlock];
    [operation perform];
}

@end
