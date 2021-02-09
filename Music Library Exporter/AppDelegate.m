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

@import Sentry;

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

#if SENTRY_ENABLED == 1
  [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = @"https://157b5edf2ba84c86b4ebf0b8d50d2d26@o370998.ingest.sentry.io/5628302";
     // options.debug = YES;
  }];
#endif
  
  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"LastExportedAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"NextExportAt" options:NSKeyValueObservingOptionNew context:NULL];

  // detect changes in NSUSerDefaults for app group
  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  [_exportConfiguration setOutputDirectoryBookmarkKeySuffix:@"Main"];
  [_exportConfiguration loadPropertiesFromUserDefaults];
  _exportDelegate = [ExportDelegate exporterWithConfig:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];

  _helperDelegate = [[HelperDelegate alloc] init];

  configurationViewController = [[ConfigurationViewController alloc] initWithExportDelegate:_exportDelegate
                                                                          andScheduleConfig:_scheduleConfiguration
                                                                          forHelperDelegate:_helperDelegate];

  // add configurationView to window contentview
  [configurationViewController.view setFrame:_window.contentView.frame];
  [_window.contentView addSubview:configurationViewController.view];
  [_window setInitialFirstResponder:configurationViewController.firstResponderView];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  NSLog(@"AppDelegate [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:@"ScheduleInterval"] ||
      [aKeyPath isEqualToString:@"LastExportedAt"] ||
      [aKeyPath isEqualToString:@"NextExportAt"]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [configurationViewController updateFromConfiguration];
  }
}

@end
