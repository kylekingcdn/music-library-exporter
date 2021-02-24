//
//  MLESentryHandler.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-22.
//

#import "MLESentryHandler.h"

#include "Defines.h"

@import Sentry;


@implementation MLESentryHandler

+ (void)setup {

  NSString* sentryDsn = SENTRY_DSN;

  if (sentryDsn && sentryDsn.length > 0) {

    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = [NSString stringWithFormat:@"https://%@", sentryDsn];
      options.releaseName = [NSString stringWithFormat:@"%@@%@+%d", __MLE__AppBundleIdentifier, CURRENT_PROJECT_VERSION, VERSION_BUILD];
      options.environment = SENTRY_ENVIRONMENT;
    }];
  }
}

@end
