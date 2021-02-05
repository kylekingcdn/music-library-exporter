//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Utils.h"
#import "HelperDelegate.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"
#import "ConfigurationViewController.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end


@implementation AppDelegate {

  ConfigurationViewController* configurationViewController;

  HelperDelegate* _helperDelegate;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _helperDelegate = [[HelperDelegate alloc] init];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  _exportDelegate = [[ExportDelegate alloc] initWithConfiguration:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];

  configurationViewController = [[ConfigurationViewController alloc] initWithExportDelegate:_exportDelegate
                                                                          andScheduleConfig:_scheduleConfiguration
                                                                          forHelperDelegate:_helperDelegate];

  [_window setContentView:[configurationViewController view]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end
