//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

#import "ConfigurationViewController.h"


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;


@end


@implementation AppDelegate {

  ConfigurationViewController* configurationViewController;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  configurationViewController = [[ConfigurationViewController alloc] init];
  [_window setContentView:[configurationViewController view]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end
