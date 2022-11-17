//
//  AppDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)showPlaylistsView;
- (void)hidePlaylistsView;

- (IBAction)showPreferencesWindow:(id)sender;

- (NSInteger)launchCount;
- (BOOL)isFirstLaunch;
- (void)incrementLaunchCount;

- (void)showCrashReportingPermissionsWindow;

@end

