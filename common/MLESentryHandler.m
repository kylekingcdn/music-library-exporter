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


@implementation MLESentryHandler

+ (void)setup {

  NSString* sentryDsn = SENTRY_DSN;

  if (sentryDsn && sentryDsn.length > 0) {

    NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
    [groupDefaults registerDefaults:@{ @"CrashReporting":@YES }];
    BOOL sentryEnabled = [groupDefaults boolForKey:@"CrashReporting"];

    MLE_Log_Info(@"MLESentryHandler [setup] sentryEnabled:%@", (sentryEnabled ? @"YES" : @"NO"));

    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = [NSString stringWithFormat:@"https://%@", sentryDsn];
      options.releaseName = [NSString stringWithFormat:@"%@@%@+%d", __MLE__AppBundleIdentifier, CURRENT_PROJECT_VERSION, VERSION_BUILD];
      options.environment = SENTRY_ENVIRONMENT;
      options.enabled = sentryEnabled;
    }];
  }
}

+ (void)setEnabled:(BOOL)flag {

  MLE_Log_Info(@"MLESentryHandler [setEnabled:%@]", (flag ? @"YES" : @"NO"));

  NSString* sentryDsn = SENTRY_DSN;
  
  if (sentryDsn && sentryDsn.length > 0) {
    [SentrySDK.currentHub.getClient.options setEnabled:NO];
  }
}

@end
