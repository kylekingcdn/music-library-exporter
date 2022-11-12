//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>
#import <iTunesLibrary/ITLibrary.h>

#import "Logger.h"
#import "Utils.h"
#import "UserDefaultsExportConfiguration.h"
#import "ScheduleConfiguration.h"
#import "HelperDelegate.h"
#import "ConfigurationViewController.h"
#import "PlaylistsViewController.h"
#import "PreferencesWindowController.h"
#if SENTRY_ENABLED == 1
#import "MLESentryHandler.h"
#endif

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end


@implementation AppDelegate {

  NSUserDefaults* _groupDefaults;

  ITLibrary* _library;

  HelperDelegate* _helperDelegate;

  UserDefaultsExportConfiguration* _exportConfiguration;

  ScheduleConfiguration* _scheduleConfiguration;

  ConfigurationViewController* _configurationViewController;
  PlaylistsViewController* _playlistsViewController;
  NSWindow* _playlistsViewWindow;

  PreferencesWindowController* _preferencesWindowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

#if SENTRY_ENABLED == 1
  [[MLESentryHandler sharedSentryHandler] setupSentry];
#endif

  // init exportConfiguration
  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] init];
  [_exportConfiguration setOutputDirectoryBookmarkKeySuffix:@"Main"];
  [_exportConfiguration loadPropertiesFromUserDefaults];

  // set shared exportConfiguration
  [UserDefaultsExportConfiguration initSharedConfig:_exportConfiguration];

  // init scheduleConfiguration
  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  [_scheduleConfiguration loadPropertiesFromUserDefaults];

  // set shared scheduleConfiguration
  [ScheduleConfiguration initSharedConfig:_scheduleConfiguration];

  // detect changes in NSUSerDefaults for app group
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleEnabled" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"LastExportedAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"NextExportAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"OutputDirectoryPath" options:NSKeyValueObservingOptionNew context:NULL];

  _helperDelegate = [[HelperDelegate alloc] init];

  _configurationViewController = [[ConfigurationViewController alloc] initWithHelperDelegate:_helperDelegate];
  // add configurationView to window contentview
  [_configurationViewController.view setFrame:_window.contentView.frame];
  [_window.contentView addSubview:_configurationViewController.view];
  [_window setInitialFirstResponder:_configurationViewController.firstResponderView];

  [_window makeKeyAndOrderFront:NSApp];

#if SENTRY_ENABLED == 1
  // prompt for crash reporting permissions if not prompted yet and not first launch
  if (!self.isFirstLaunch && !MLESentryHandler.sharedSentryHandler.userHasBeenPromptedForCrashReportingPermissions) {
    [self showCrashReportingPermissionsWindow];
    [[MLESentryHandler sharedSentryHandler] setUserHasBeenPromptedForCrashReportingPermissions:YES];
  }
#endif

  [self incrementLaunchCount];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {

  return YES;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"AppDelegate [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:@"ScheduleInterval"] ||
      [aKeyPath isEqualToString:@"LastExportedAt"] ||
      [aKeyPath isEqualToString:@"NextExportAt"] ||
      [aKeyPath isEqualToString:@"ScheduleEnabled"] ||
      [aKeyPath isEqualToString:@"OutputDirectoryPath"]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [_configurationViewController updateFromConfiguration];

    if ([aKeyPath isEqualToString:@"ScheduleEnabled"]) {
      [_helperDelegate updateHelperRegistrationWithScheduleEnabled:_scheduleConfiguration.scheduleEnabled];
    }
  }
}

- (void)showPlaylistsView {

  if (_playlistsViewController == nil) {

    // init playlistsView
    _playlistsViewController = [[PlaylistsViewController alloc] init];
    _playlistsViewWindow = [NSWindow windowWithContentViewController:_playlistsViewController];
    [_playlistsViewWindow setFrameAutosaveName:@"PlaylistsWindow"];
    [_playlistsViewWindow setTitle:@"Playlists"];
  }

  [_playlistsViewWindow makeKeyAndOrderFront:NSApp];
}

- (void)hidePlaylistsView {

  [_playlistsViewWindow orderOut:NSApp];
}

- (IBAction)showPreferencesWindow:(id)sender {

  if (_preferencesWindowController && !_preferencesWindowController.window.isVisible) {
    [_preferencesWindowController.window close];
    _preferencesWindowController = nil;
  }

  if (_preferencesWindowController == nil) {
    _preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
  }

  [_preferencesWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction)openMusicLibraryExporterWebsite:(id)sender {

  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://music-exporter.app/"]];
}

- (IBAction)contactSupport:(id)sender {

  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:support@music-exporter.app"]];
}

- (NSInteger)launchCount {

  [_groupDefaults registerDefaults:@{ @"LaunchCount":@0 }];

  return [_groupDefaults integerForKey:@"LaunchCount"];
}

- (BOOL)isFirstLaunch {

  return [self launchCount] == 0;
}

- (void)incrementLaunchCount {

  NSInteger launchCount = [self launchCount];
  launchCount++;
  [_groupDefaults setInteger:launchCount forKey:@"LaunchCount"];
}

- (void)showCrashReportingPermissionsWindow {
#if SENTRY_ENABLED == 1
  MLE_Log_Info(@"AppDelegate [showCrashReportingPermissionsWindow]");

  // show alert
  NSAlert* crashReportingPermissionAlert = [[NSAlert alloc] init];
  [crashReportingPermissionAlert setAlertStyle:NSAlertStyleInformational];
  [crashReportingPermissionAlert setMessageText:@"Enable automatic crash reporting?"];
  [crashReportingPermissionAlert setInformativeText:
   @"Sending us crash reports helps us improve our software.\n\n"
   "Reports are anonymous. They do not contain any personally identifiable information.\n\n"
   "This can be changed at any time from the application's preferences."];
  [crashReportingPermissionAlert addButtonWithTitle:@"Yes"];
  [[crashReportingPermissionAlert addButtonWithTitle:@"No"] setKeyEquivalent:@"\e"];
  NSModalResponse response = [crashReportingPermissionAlert runModal];

  // update preference
  BOOL enableCrashReporting = (response == NSAlertFirstButtonReturn);
  [MLESentryHandler setCrashReportingEnabled:enableCrashReporting];
#endif
}

@end
