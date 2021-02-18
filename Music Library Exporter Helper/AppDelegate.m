//
//  AppDelegate.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-01-26.
//

#import "AppDelegate.h"

#import <iTunesLibrary/ITLibrary.h>

#import "Logger.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"
#import "ScheduleDelegate.h"

@import Sentry;

@implementation AppDelegate {

  ITLibrary* _library;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
  ScheduleDelegate* _scheduleDelegate;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

#if SENTRY_ENABLED == 1
  NSString* sentryDsn = SENTRY_DSN;
  if (sentryDsn && sentryDsn.length > 0) {
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = [NSString stringWithFormat:@"https://%@", sentryDsn];
    }];
  }
#endif

  // init exportConfiguration
  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] init];
  [_exportConfiguration setOutputDirectoryBookmarkKeySuffix:@"Helper"];
  [_exportConfiguration loadPropertiesFromUserDefaults];

  // set shared exportConfiguration
  [UserDefaultsExportConfiguration initSharedConfig:_exportConfiguration];

  // init scheduleConfiguration
  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  [_scheduleConfiguration loadPropertiesFromUserDefaults];

  // set shared scheduleConfiguration
  [ScheduleConfiguration initSharedConfig:_scheduleConfiguration];

  // init ITLibrary
  NSError *error = nil;
  _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];
  if (!_library) {
    MLE_Log_Info(@"AppDelegate [applicationDidFinishLaunching] error - failed to init ITLibrary. error: %@", error.localizedDescription);
    return;
  }

  _exportDelegate = [[ExportDelegate alloc] initWithLibrary:_library];

  // init scheduleDelegate
  _scheduleDelegate = [[ScheduleDelegate alloc] initWithExportDelegate:_exportDelegate];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  [_scheduleDelegate deactivateScheduler];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
