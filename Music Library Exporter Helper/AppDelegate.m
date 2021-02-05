//
//  AppDelegate.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-01-26.
//

#import "AppDelegate.h"

#import "Defines.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"
#import "ScheduleDelegate.h"

@implementation AppDelegate {

  NSUserDefaults* _groupDefaults;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
  ScheduleDelegate* _scheduleDelegate;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

  // detect changes in NSUSerDefaults for app group
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"NextExportAt" options:NSKeyValueObservingOptionNew context:NULL];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  _exportDelegate = [[ExportDelegate alloc] initWithConfiguration:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  _scheduleDelegate = [[ScheduleDelegate alloc] initWithExportDelegate:_exportDelegate];

  [_scheduleDelegate setInterval:_scheduleConfiguration.scheduleInterval];
  [_scheduleDelegate activateScheduler];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  [_scheduleDelegate deactivateScheduler];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {
  
  NSLog(@"AppDelegate [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:@"ScheduleInterval"]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [_scheduleDelegate setInterval:_scheduleConfiguration.scheduleInterval];
  }
  else if ([aKeyPath isEqualToString:@"NextExportAt"]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];

    // TODO: finish me
  }
}

@end
