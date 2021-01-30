//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

#import "ConfigurationViewController.h"

static NSString* const _appGroupIdentifier = @"group.9YLM7HTV6V.com.MusicLibraryExporter";
static NSString* const _helperBundleIdentifier = @"com.kylekingcdn.MusicLibraryExporter.MusicLibraryExporterHelper";


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;


@end


@implementation AppDelegate {

  ConfigurationViewController* configurationViewController;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  configurationViewController = [[ConfigurationViewController alloc] init];
  NSView * contentView = [_window contentView];
  [contentView addSubview: [configurationViewController view]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end
