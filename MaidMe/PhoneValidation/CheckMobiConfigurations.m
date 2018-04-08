//
//  CheckMobiConfigurations.m
//  MaidMe
//
//  Created by Mohammad Alatrash on 4/21/17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "CheckMobiConfigurations.h"
#import "CheckMobiService.h"

@implementation CheckMobiConfigurations
    
+ (void)setup {
    [[CheckMobiService sharedInstance] setSecretKey:@"21B116D6-36A3-491C-BFB4-A67EAA53B6A2"];
}

+ (void)requestValidation:(NSString *)phoneNumber completion:(completionBlock)completion {

    [[CheckMobiService sharedInstance] RequestValidation: ValidationTypeSMS forNumber:phoneNumber withResponse:^(NSInteger status, NSDictionary* result, NSError* error)
     {
         NSString* errorMessage = [self validationErrorMessage:status withBody:result withError:error];
         NSLog(@"status= %ld result=%@", (long)status, result);
         
         if (status == kStatusSuccessWithContent && result != nil) {
             NSString* key = [result objectForKey:@"id"];
             completion(key, errorMessage);
         } else {
             completion(nil, errorMessage);
         }
     }];
}

+ (void)verifyPin:(NSString* )userPin validationKey:(NSString *)key completion:(pinValidationBlock) completion {
    [[CheckMobiService sharedInstance] VerifyPin:key withPin:userPin withResponse:^(NSInteger status, NSDictionary * result, NSError* error) {
         
         if(status == kStatusSuccessWithContent && result != nil) {
             NSNumber *validated = [result objectForKey:@"validated"];
             
             if(![validated boolValue]) {
                 completion(NO, error);
                 return;
             }
             completion(YES, nil);
         } else {
             completion(NO, error);
         }
     }];
}
    
+(NSString*)validationErrorMessage:(NSInteger)http_status withBody:(NSDictionary*)body withError:(NSError*)error {
    
    NSString *error_message;

    if (body) {
        enum ErrorCode error = (enum ErrorCode)[[body valueForKey:@"code"] intValue];

        switch (error) {
            case ErrorCodeInvalidPhoneNumber:
            error_message = @"Invalid phone number. Please provide the number in E164 format.";
            break;
            
            default:
            error_message = @"Service unavailable. Please try later.";
        }
    }else {
        error_message = @"Service unavailable. Please try later.";
    }
    
    return error_message;
}

@end
