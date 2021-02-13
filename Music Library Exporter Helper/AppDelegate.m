//
//  AppDelegate.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-01-26.
//

#import "AppDelegate.h"

#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"
#import "ScheduleDelegate.h"

@import Sentry;

@implementation AppDelegate {

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
  ScheduleDelegate* _scheduleDelegate;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

#if SENTRY_ENABLED == 1
  [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = @"https://1583cd6331cc43d69783685cbd74f668@o370998.ingest.sentry.io/5628302";
     // options.debug = YES;
  }];
#endif

  // init exportConfiguration
  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  [_exportConfiguration setOutputDirectoryBookmarkKeySuffix:@"Helper"];
  [_exportConfiguration loadPropertiesFromUserDefaults];

  // set shared exportConfiguration
  [UserDefaultsExportConfiguration initSharedConfig:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];

  _exportDelegate = [ExportDelegate exporter];
  
  _scheduleDelegate = [ScheduleDelegate schedulerWithConfig:_scheduleConfiguration andExporter:_exportDelegate];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  [_scheduleDelegate deactivateScheduler];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
