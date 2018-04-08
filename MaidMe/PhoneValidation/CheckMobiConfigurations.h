//
//  CheckMobiConfigurations.h
//  MaidMe
//
//  Created by Mohammad Alatrash on 4/21/17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckMobiConfigurations : NSObject

typedef void(^completionBlock)(NSString* __nullable key, NSString* __nullable errorMessage);
typedef void(^pinValidationBlock)(BOOL success, NSError* __nullable error);

+ (void) setup;
+ (void)requestValidation:(NSString *)phoneNumber completion:(completionBlock)completion;
+ (void)verifyPin:(NSString* )userPin validationKey:(NSString *)key completion:(pinValidationBlock) completion;
@end
