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

@implementation AppDelegate {

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
  ScheduleDelegate* _scheduleDelegate;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  _exportDelegate = [ExportDelegate exporterWithConfig:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  _scheduleDelegate = [ScheduleDelegate schedulerWithConfig:_scheduleConfiguration andExporter:_exportDelegate];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  [_scheduleDelegate deactivateScheduler];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
