//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Logger.h"
#import "UserDefaultsExportConfiguration.h"
#import "ScheduleConfiguration.h"
#import "DirectoryBookmarkHandler.h"
#import "HelperAppManager.h"
#import "ConfigurationViewController.h"
#import "PlaylistsViewController.h"
#import "PreferencesWindowController.h"
#if SENTRY_ENABLED == 1
#import "SentryHandler.h"
#endif

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end


@implementation AppDelegate {

  NSUserDefaults* _groupDefaults;

  HelperAppManager* _helperAppManager;

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
  [[SentryHandler sharedSentryHandler] setupSentry];
#endif

  // init exportConfiguration
  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithOutputDirectoryBookmarkKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
  [_exportConfiguration loadPropertiesFromUserDefaults];

  // resolve output directory bookmark data
  DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
  [_exportConfiguration setOutputDirectoryUrl:[bookmarkHandler urlFromDefaultsAndReturnError:nil]];

  // init scheduleConfiguration
  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];
  [_scheduleConfiguration loadPropertiesFromUserDefaults];

  // detect changes in NSUSerDefaults for app group
  [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyScheduleEnabled options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyScheduleInterval options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyLastExportedAt options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyNextExportAt options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:ExportConfigurationKeyOutputDirectoryPath options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:OUTPUT_DIRECTORY_BOOKMARK_KEY options:NSKeyValueObservingOptionNew context:NULL];

  // init helper manager and ensure helper registration status matches configuration value for scheduleEnabled
  _helperAppManager = [[HelperAppManager alloc] init];
  [_helperAppManager updateHelperRegistrationWithScheduleEnabled:_scheduleConfiguration.scheduleEnabled];

  _configurationViewController = [[ConfigurationViewController alloc] initWithExportConfiguration:_exportConfiguration
                                                                         andScheduleConfiguration:_scheduleConfiguration];

  // add configurationView to window contentview
  [_configurationViewController.view setFrame:_window.contentView.frame];
  [_window.contentView addSubview:_configurationViewController.view];
  [_window setInitialFirstResponder:_configurationViewController.firstResponderView];
  [_window setExcludedFromWindowsMenu:YES];
  [_window setReleasedWhenClosed:NO];

  [_window makeKeyAndOrderFront:NSApp];

#if SENTRY_ENABLED == 1
  // prompt for crash reporting permissions if not prompted yet and not first launch
  if (!self.isFirstLaunch && !SentryHandler.sharedSentryHandler.userHasBeenPromptedForCrashReportingPermissions) {
    [self showCrashReportingPermissionsWindow];
    [[SentryHandler sharedSentryHandler] setUserHasBeenPromptedForCrashReportingPermissions:YES];
  }
#endif

  [self incrementLaunchCount];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {

  return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {

  return ([_window isVisible] == NO);
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender {

  if ([_window isVisible]) {
    return NO;
  }

  [self showConfigurationView:self];
  return YES;
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {

  [self showConfigurationView:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {

  [self showConfigurationView:self];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"AppDelegate [observeValueForKeyPath:%@]", aKeyPath);

  // update the OutputDirectoryPath variable *only* when the main application's URL bookmark changes.
  // This allows stale bookmark updates to be propagated while also ensuring that the helper application URL bookmark is consistent and synchronized
  if ([aKeyPath isEqualToString:OUTPUT_DIRECTORY_BOOKMARK_KEY]) {
    [_exportConfiguration setOutputDirectoryPath:_exportConfiguration.outputDirectoryUrl.path];
  }

  else if ([aKeyPath isEqualToString:ScheduleConfigurationKeyScheduleInterval] ||
      [aKeyPath isEqualToString:ScheduleConfigurationKeyLastExportedAt] ||
      [aKeyPath isEqualToString:ScheduleConfigurationKeyNextExportAt] ||
      [aKeyPath isEqualToString:ScheduleConfigurationKeyScheduleEnabled] ||
      [aKeyPath isEqualToString:ExportConfigurationKeyOutputDirectoryPath]) {

    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [_configurationViewController updateFromConfiguration];

    if ([aKeyPath isEqualToString:ScheduleConfigurationKeyScheduleEnabled]) {
      [_helperAppManager updateHelperRegistrationWithScheduleEnabled:_scheduleConfiguration.scheduleEnabled];
    }
  }
}

- (IBAction)showConfigurationView:(id)sender {

  [_window makeKeyAndOrderFront:self];
  
  [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showPlaylistsView:(id)sender {

  if (_playlistsViewController == nil) {

    // init playlistsView
    _playlistsViewController = [[PlaylistsViewController alloc] initWithExportConfiguration:_exportConfiguration];
    _playlistsViewWindow = [NSWindow windowWithContentViewController:_playlistsViewController];
    [_playlistsViewWindow setFrameAutosaveName:@"PlaylistsWindow"];
    [_playlistsViewWindow setTitle:@"Playlists"];
    [_playlistsViewWindow setExcludedFromWindowsMenu:YES];
    [_playlistsViewWindow setReleasedWhenClosed:NO];
  }

  [_playlistsViewWindow makeKeyAndOrderFront:NSApp];
}

- (IBAction)hidePlaylistsView:(id)sender {

  [_playlistsViewWindow orderOut:NSApp];
}

- (IBAction)showPreferencesWindow:(id)sender {

  if (_preferencesWindowController && !_preferencesWindowController.window.isVisible) {
    [_preferencesWindowController.window close];
    _preferencesWindowController = nil;
  }

  if (_preferencesWindowController == nil) {
    _preferencesWindowController = [[PreferencesWindowController alloc] init];
  }

  [_preferencesWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction)exportLibrary:(id)sender {

  [_configurationViewController.view.window makeKeyAndOrderFront:self];
  [_configurationViewController exportLibrary:sender];
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
  [SentryHandler setCrashReportingEnabled:enableCrashReporting];
#endif
}

@end
