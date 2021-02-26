//
//  MLESentryHandler.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-22.
//

#import "MLESentryHandler.h"

#include "Defines.h"
#include "Logger.h"

@import Sentry;


static MLESentryHandler* _sharedSentryHandler;


@interface MLESentryHandler ()

@property NSUserDefaults* groupDefaults;

+ (NSString*)crashReportingDefaultsKey;
+ (NSString*)promptedForPermissionsDefaultsKey;

- (nullable NSString*)sentryDsn;
- (nullable NSString*)sentryEnvironment;
- (nullable NSString*)sentryReleaseName;

- (void)setUserHasEnabledCrashReporting:(BOOL)flag;

@end


@implementation MLESentryHandler

#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  NSAssert((_sharedSentryHandler == nil), @"MLESentryHandler sharedSentryHandler has already been initialized");

  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults registerDefaults:@{ [MLESentryHandler crashReportingDefaultsKey]:@NO }];
  [_groupDefaults registerDefaults:@{ [MLESentryHandler promptedForPermissionsDefaultsKey]:@NO }];
  [_groupDefaults addObserver:self forKeyPath:[MLESentryHandler crashReportingDefaultsKey] options:NSKeyValueObservingOptionNew context:NULL];

  return self;
}


#pragma mark - Accessors

+ (MLESentryHandler*)sharedSentryHandler {

  if (_sharedSentryHandler == nil) {
    _sharedSentryHandler = [[MLESentryHandler alloc] init];
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

  return [_groupDefaults boolForKey:[MLESentryHandler crashReportingDefaultsKey]];
}

- (BOOL)userHasBeenPromptedForCrashReportingPermissions {

  return [_groupDefaults boolForKey:[MLESentryHandler promptedForPermissionsDefaultsKey]];
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
    MLE_Log_Error(@"MLESentryHandler [setupSentry] error - sentry dsn is unset");
    return;
  }

  BOOL sentryEnabled = [self userHasEnabledCrashReporting];
  NSString* sentryReleaseName = [self sentryReleaseName];
  NSString* sentryEnvironment = [self sentryEnvironment];
  MLE_Log_Info(@"MLESentryHandler [setupSentry] enabled:%@ release:%@ environment:%@", (sentryEnabled ? @"YES" : @"NO"), sentryReleaseName, sentryEnvironment);

  [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
    options.dsn = sentryDsn;
    options.enabled = sentryEnabled;
    options.releaseName = sentryReleaseName;
    options.environment = sentryEnvironment;
  }];
}

- (void)setUserHasEnabledCrashReporting:(BOOL)flag {

  [_groupDefaults setBool:flag forKey:[MLESentryHandler crashReportingDefaultsKey]];
}

- (void)setUserHasBeenPromptedForCrashReportingPermissions:(BOOL)flag {

  [_groupDefaults setBool:flag forKey:[MLESentryHandler promptedForPermissionsDefaultsKey]];
}

- (void)setSentryEnabled:(BOOL)flag {

  MLE_Log_Info(@"MLESentryHandler [setSentryEnabled:%@]", (flag ? @"YES" : @"NO"));

  [SentrySDK.currentHub.getClient.options setEnabled:NO];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"MLESentryHandler [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:[MLESentryHandler crashReportingDefaultsKey]]) {
    BOOL crashReportingEnabled = [self userHasEnabledCrashReporting];
    [self setSentryEnabled: crashReportingEnabled];
  }
}

+ (void)setCrashReportingEnabled:(BOOL)flag {

  if (_sharedSentryHandler != nil) {

    MLE_Log_Info(@"MLESentryHandler [setCrashReportingEnabled:%@]", (flag ? @"YES" : @"NO"));

    [_sharedSentryHandler setSentryEnabled:flag];
    [_sharedSentryHandler setUserHasEnabledCrashReporting:flag];
  }
}

@end
