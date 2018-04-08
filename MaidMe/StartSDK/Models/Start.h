//
//  Start.h
//  StartSDK
//
//  Created by Viktor on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** StartSDK shows alert informing a user that 3D secure verification is required and a web view will be shown.
 * To customize (and localize) the alert, localize string for the keys below using Lozalizable.strings.
 */

/** Localization key of the message of the alert informing a user that 3D secure verification is required and a web view will be shown.
 * Default string is "Card verification process is required by your bank (3D Secure). It will start in a bit.".
 */
#define StartLocalizationKeyVerificationMessage @"payfort_start_verification_message"

/** Localization key of the button title of the alert informing a user that 3D secure verification is required and a web view will be shown.
 * Default string is "OK".
 */
#define StartLocalizationKeyVerificationButton @"payfort_start_verification_button"

@protocol StartToken;
@class StartCard;

typedef void (^StartSuccessBlock)(id <StartToken> token);

/** @warning Error could have either StartError domain or one of standard iOS SDK domains. */
typedef void (^StartErrorBlock)(NSError *error);

typedef void (^StartCancelBlock)();

/** Code of error with StartError domain. */
typedef NS_ENUM(NSInteger, StartErrorCode) {
    /** Error occured inside either StartSDK or its API. */
    StartErrorCodeInternalError,
    /** Error occured when Start is initialized with invalid API key. */
    StartErrorCodeInvalidAPIKey,
    /** Error occured when trying to create StartToken for zero or negative amount of charge. */
    StartErrorCodeInvalidAmount,
    /** Error occured when trying to create StartToken with invalid currency of charge. */
    StartErrorCodeInvalidCurrency
};

/** Domain of error occured when executing Start methods.
 *
 * @warning Standard iOS SDK errors (f.e. error with NSURLErrorDomain domain) can also occure when executing Start methods.
 */
extern NSErrorDomain const StartError;

/** Error userInfo key of NSString containing the response received from API */
extern NSString *const StartErrorKeyResponse;

/** Allows creating StartToken that can be used for making card charges. */
@interface Start : NSObject

/** Creates Start object.
 *
 * @param apiKey API key of Start account.
 *
 * @returns Start object created.
 *
 * @see https://docs.start.payfort.com/guides/api_keys/#how-to-get-api-keys.
 */
+ (instancetype)startWithAPIKey:(NSString *)apiKey;

/** Creates StartToken for charge of amount of currency specified using StartCard specified.
 *
 * @param card StartCard representation of the card to commit the charge.
 * @param amount Charge amount in cents.
 * @param currency Charge currency, f.e. "USD".
 * @param successBlock Block called on StartToken created.
 * @param errorBlock Block called on error occured during StartToken creation.
 * @param cancelBlock Block called when a user cancels 3D Secure verification making impossible StartToken creation.
 */
- (void)createTokenForCard:(StartCard *)card
                    amount:(NSInteger)amount
                  currency:(NSString *)currency
              successBlock:(StartSuccessBlock)successBlock
                errorBlock:(StartErrorBlock)errorBlock
               cancelBlock:(StartCancelBlock)cancelBlock;

@end

NS_ASSUME_NONNULL_END
