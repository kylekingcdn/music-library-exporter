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
#import "ExportDelegate.h"
#import "HelperDelegate.h"
#import "ConfigurationViewController.h"
#import "PlaylistsViewController.h"

@import Sentry;

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end


@implementation AppDelegate {

  NSUserDefaults* _groupDefaults;

  ITLibrary* _library;

  HelperDelegate* _helperDelegate;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;

  ConfigurationViewController* _configurationViewController;
  PlaylistsViewController* _playlistsViewController;
  NSWindow* _playlistsViewWindow;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

#if SENTRY_ENABLED == 1
  NSString* sentryDsn = [NSString stringWithFormat:@"https://%@", SENTRY_DSN];
  if (sentryDsn && sentryDsn.length > 0) {
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
      options.dsn = sentryDsn;
      options.releaseName = [NSString stringWithFormat:@"%@@%@+%d", __MLE__AppBundleIdentifier, CURRENT_PROJECT_VERSION, VERSION_BUILD];
    }];
  }
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
  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleEnabled" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"LastExportedAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"NextExportAt" options:NSKeyValueObservingOptionNew context:NULL];

  // init ITLibrary
  NSError *error = nil;
  _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];
  if (_library == nil) {
    MLE_Log_Info(@"AppDelegate [applicationDidFinishLaunching] error - failed to init ITLibrary. error: %@", error.localizedDescription);
    return;
  }

  _exportDelegate = [[ExportDelegate alloc] initWithLibrary:_library];

  _helperDelegate = [[HelperDelegate alloc] init];

  _configurationViewController = [[ConfigurationViewController alloc] initWithExportDelegate:_exportDelegate
                                                                          forHelperDelegate:_helperDelegate];
  // add configurationView to window contentview
  [_configurationViewController.view setFrame:_window.contentView.frame];
  [_window.contentView addSubview:_configurationViewController.view];
  [_window setInitialFirstResponder:_configurationViewController.firstResponderView];

  [_window makeKeyAndOrderFront:NSApp];
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
      [aKeyPath isEqualToString:@"ScheduleEnabled"]) {

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
    _playlistsViewController = [[PlaylistsViewController alloc] initWithLibrary:_library];
    _playlistsViewWindow = [NSWindow windowWithContentViewController:_playlistsViewController];
    [_playlistsViewWindow setTitle:@"Playlists"];
  }

  if (!_playlistsViewWindow.isVisible) {
    // update playlists window frame
    NSRect playlistsViewWindowFrame = _window.frame;
    playlistsViewWindowFrame.origin.x += (_window.frame.size.width + 20);
    [_playlistsViewWindow setFrame:playlistsViewWindowFrame display:YES];
  }

  [_playlistsViewWindow makeKeyAndOrderFront:NSApp];
}

- (void)hidePlaylistsView {

  [_playlistsViewWindow orderOut:NSApp];
}

- (IBAction)openMusicLibraryExporterWebsite:(id)sender {

  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://music-exporter.app/"]];
}

- (IBAction)contactSupport:(id)sender {

  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:support@music-exporter.app"]];
}

@end
