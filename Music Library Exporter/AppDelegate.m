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

  NSUserDefaults* _groupDefaults;

  HelperDelegate* _helperDelegate;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;

  ConfigurationViewController* configurationViewController;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

  // detect changes in NSUSerDefaults for app group
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"NextExportAt" options:NSKeyValueObservingOptionNew context:NULL];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  _exportDelegate = [[ExportDelegate alloc] initWithConfiguration:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];

  _helperDelegate = [[HelperDelegate alloc] init];

  configurationViewController = [[ConfigurationViewController alloc] initWithExportDelegate:_exportDelegate
                                                                          andScheduleConfig:_scheduleConfiguration
                                                                          forHelperDelegate:_helperDelegate];

  [_window setContentView:[configurationViewController view]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  NSLog(@"AppDelegate [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:@"ScheduleInterval"]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [_scheduleConfiguration setScheduleInterval:_scheduleConfiguration.scheduleInterval];
  }
  else if ([aKeyPath isEqualToString:@"NextExportAt"]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];

    // TODO: finish me
  }
}

@end
