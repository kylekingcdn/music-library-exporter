//
//  AppDelegate.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-01-26.
//

#import "AppDelegate.h"

@interface AppDelegate () {

  NSString* _appGroupIdentifier;
}

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _appGroupIdentifier = @"group.9YLM7HTV6V.com.MusicLibraryExporter";

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  if (groupDefaults) {

  }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {

}


@end
