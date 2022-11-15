//
//  HelperAppDelegate.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-01-26.
//

#import "HelperAppDelegate.h"

#import "Logger.h"
#import "UserDefaultsExportConfiguration.h"
#import "ScheduleConfiguration.h"
#import "ExportScheduler.h"
#if SENTRY_ENABLED == 1
#import "SentryHandler.h"
#endif

@implementation HelperAppDelegate {

  UserDefaultsExportConfiguration* _exportConfiguration;

  ScheduleConfiguration* _scheduleConfiguration;
  ExportScheduler* _exportScheduler;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _exportConfiguration = nil;

    _scheduleConfiguration = nil;
    _exportScheduler = nil;
    
    return self;
  }
  else {
    return nil;
  }
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

#if SENTRY_ENABLED == 1
  [[SentryHandler sharedSentryHandler] setupSentry];
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

  // init scheduleDelegate
  _exportScheduler = [[ExportScheduler alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  [_exportScheduler deactivateScheduler];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
