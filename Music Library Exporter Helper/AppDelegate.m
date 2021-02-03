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
#import "ExportScheduleDelegate.h"

@interface AppDelegate () {

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
  ExportScheduleDelegate* _scheduleDelegate;
}

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  _exportDelegate = [[ExportDelegate alloc] initWithConfiguration:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  _scheduleDelegate = [[ExportScheduleDelegate alloc] initWithConfiguration:_scheduleConfiguration andExportDelegate:_exportDelegate];

  if (!_exportConfiguration.isOutputDirectoryValid) {
    //[self getDirectoryWritePermissions];
  }
  else {
    [_scheduleDelegate activateScheduler];
  }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {

}


@end
