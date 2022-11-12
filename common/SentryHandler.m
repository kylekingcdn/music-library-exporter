//
//  SentryHandler.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-22.
//

#import "SentryHandler.h"

#include "Defines.h"
#include "Logger.h"

@import Sentry;


static SentryHandler* _sharedSentryHandler;


@interface SentryHandler ()

@property NSUserDefaults* groupDefaults;

+ (NSString*)crashReportingDefaultsKey;
+ (NSString*)promptedForPermissionsDefaultsKey;

- (nullable NSString*)sentryDsn;
- (nullable NSString*)sentryEnvironment;
- (nullable NSString*)sentryReleaseName;

- (void)setUserHasEnabledCrashReporting:(BOOL)flag;

@end


@implementation SentryHandler

#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  NSAssert((_sharedSentryHandler == nil), @"SentryHandler sharedSentryHandler has already been initialized");

  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults registerDefaults:@{ [SentryHandler crashReportingDefaultsKey]:@NO }];
  [_groupDefaults registerDefaults:@{ [SentryHandler promptedForPermissionsDefaultsKey]:@NO }];
  [_groupDefaults addObserver:self forKeyPath:[SentryHandler crashReportingDefaultsKey] options:NSKeyValueObservingOptionNew context:NULL];

  return self;
}


#pragma mark - Accessors

+ (SentryHandler*)sharedSentryHandler {

  if (_sharedSentryHandler == nil) {
    _sharedSentryHandler = [[SentryHandler alloc] init];
  }

  return _sharedSentryHandler;
}

+ (NSString*)crashReportingDefaultsKey {

  return @"CrashReporting";
}

+ (NSString*)promptedForPermissionsDefaultsKey {

  return @"PromptedForCrashReporting";
}

- (BOOL)userHasEnabledCrashReporting {

  return [_groupDefaults boolForKey:[SentryHandler crashReportingDefaultsKey]];
}

- (BOOL)userHasBeenPromptedForCrashReportingPermissions {

  return [_groupDefaults boolForKey:[SentryHandler promptedForPermissionsDefaultsKey]];
}

- (nullable NSString*)sentryDsn {

  NSString* envDsn = SENTRY_DSN;

  if (envDsn && envDsn.length > 0) {
    return [NSString stringWithFormat:@"https://%@", envDsn];
  }

  return nil;
}

- (nullable NSString*)sentryEnvironment {

  NSString* envEnvironment = SENTRY_ENVIRONMENT;

  if (envEnvironment && envEnvironment.length > 0) {
    return envEnvironment;
  }

  return nil;
}

- (nullable NSString*)sentryReleaseName {

  NSString* appId = __MLE__AppBundleIdentifier;
  NSString* versionString = CURRENT_PROJECT_VERSION;
  NSUInteger versionBuild = VERSION_BUILD;

  NSString* sentryReleaseName = [NSString stringWithFormat:@"%@@%@+%lu", appId, versionString, versionBuild];

  return sentryReleaseName;
}

#pragma mark - Mutators

- (void)setupSentry {

  NSString* sentryDsn = [self sentryDsn];
  if (sentryDsn == nil) {
    MLE_Log_Error(@"SentryHandler [setupSentry] error - sentry dsn is unset");
    return;
  }

  BOOL sentryEnabled = [self userHasEnabledCrashReporting];
  NSString* sentryReleaseName = [self sentryReleaseName];
  NSString* sentryEnvironment = [self sentryEnvironment];
  MLE_Log_Info(@"SentryHandler [setupSentry] enabled:%@ release:%@ environment:%@", (sentryEnabled ? @"YES" : @"NO"), sentryReleaseName, sentryEnvironment);

  [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
    options.dsn = sentryDsn;
    options.enabled = sentryEnabled;
    options.releaseName = sentryReleaseName;
    options.environment = sentryEnvironment;
  }];
}

- (void)restartSentry {

  [SentrySDK close];
  [self setupSentry];
}

- (void)setUserHasEnabledCrashReporting:(BOOL)flag {

  [_groupDefaults setBool:flag forKey:[SentryHandler crashReportingDefaultsKey]];
}

- (void)setUserHasBeenPromptedForCrashReportingPermissions:(BOOL)flag {

  [_groupDefaults setBool:flag forKey:[SentryHandler promptedForPermissionsDefaultsKey]];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"SentryHandler [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:[SentryHandler crashReportingDefaultsKey]]) {
    [_sharedSentryHandler restartSentry];
  }
}

+ (void)setCrashReportingEnabled:(BOOL)flag {

  if (_sharedSentryHandler != nil) {

    MLE_Log_Info(@"SentryHandler [setCrashReportingEnabled:%@]", (flag ? @"YES" : @"NO"));

    [_sharedSentryHandler setUserHasEnabledCrashReporting:flag];
    [_sharedSentryHandler restartSentry];
  }
}

@end
