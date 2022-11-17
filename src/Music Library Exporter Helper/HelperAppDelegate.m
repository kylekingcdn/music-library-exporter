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
#import "DirectoryBookmarkHandler.h"
#import "ExportScheduler.h"
#if SENTRY_ENABLED == 1
#import "SentryHandler.h"
#endif

@implementation HelperAppDelegate {

  NSUserDefaults* _groupDefaults;

  UserDefaultsExportConfiguration* _exportConfiguration;

  ScheduleConfiguration* _scheduleConfiguration;
  ExportScheduler* _exportScheduler;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    // detect changes in NSUSerDefaults for app group
    _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
    [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyScheduleEnabled options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyScheduleInterval options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyLastExportedAt options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ExportConfigurationKeyOutputDirectoryPath options:NSKeyValueObservingOptionNew context:NULL];

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
  _exportConfiguration = [[UserDefaultsExportConfiguration alloc]  initWithOutputDirectoryBookmarkKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
  [_exportConfiguration loadPropertiesFromUserDefaults];

  // resolve output directory bookmark data
  DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
  [_exportConfiguration setOutputDirectoryUrl:[bookmarkHandler urlFromDefaultsAndReturnError:nil]];

  // init scheduleConfiguration
  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  [_scheduleConfiguration loadPropertiesFromUserDefaults];

  // init scheduleDelegate
  _exportScheduler = [[ExportScheduler alloc] initWithExportConfiguration:_exportConfiguration andScheduleConfiguration:_scheduleConfiguration];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  [_exportScheduler deactivateScheduler];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)anObject change:(NSDictionary*)aChange context:(void*)aContext {

  MLE_Log_Info(@"HelperAppDelegate [observeValueForKeyPath:%@]", keyPath);

  if ([keyPath isEqualToString:ScheduleConfigurationKeyScheduleEnabled] ||
      [keyPath isEqualToString:ScheduleConfigurationKeyScheduleInterval] ||
      [keyPath isEqualToString:ScheduleConfigurationKeyLastExportedAt] ||
      [keyPath isEqualToString:ExportConfigurationKeyOutputDirectoryPath]) {

    // fetch latest configuration values
    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [_exportConfiguration loadPropertiesFromUserDefaults];

    [_exportScheduler requestOutputDirectoryPermissionsIfRequired];
    [_exportScheduler updateSchedule];
  }
}

@end
