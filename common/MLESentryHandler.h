//
//  MLESentryHandler.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-22.
//

#import <Foundation/Foundation.h>

@class SentrySDK;


NS_ASSUME_NONNULL_BEGIN

@interface MLESentryHandler : NSObject


#pragma mark - Properties

@property (nullable, readonly) SentrySDK* sentrySdk;


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

+ (MLESentryHandler*)sharedSentryHandler;

- (BOOL)userHasEnabledCrashReporting;
- (BOOL)userHasBeenPromptedForCrashReportingPermissions;


#pragma mark - Mutators

- (void)setupSentry;
- (void)restartSentry;

- (void)setUserHasBeenPromptedForCrashReportingPermissions:(BOOL)flag;

+ (void)setCrashReportingEnabled:(BOOL)flag;



@end

NS_ASSUME_NONNULL_END
