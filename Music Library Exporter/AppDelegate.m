//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end


@implementation AppDelegate


@synthesize launchAtLoginButton;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

-(NSString*)bundleIdentifierForHelper {

  return @"com.kylekingcdn.MusicLibraryExporter.MusicLibraryExporterHelper";
}

-(NSString*)errorForSchedulerRegistration:(BOOL)registerFlag {

  if (registerFlag) {
    return @"Couldn't add Music Library Exporter Helper to launch at login item list.";
  }
  else {
    return @"Couldn't remove Music Library Exporter Helper from launch at login item list.";
  }
}

-(BOOL)isScheduled {

  return _scheduleEnabled;
}

-(void)setScheduleEnabled:(BOOL)flag {

    NSLog(@"[setScheduleEnabled:%@]", (flag ? @"YES" : @"NO"));

  _scheduleEnabled = YES;
}

-(BOOL)registerSchedulerWithSystem:(BOOL)flag {

  NSLog(@"[registerSchedulerWithSystem:%@]", (flag ? @"YES" : @"NO"));

  BOOL success = SMLoginItemSetEnabled ((__bridge CFStringRef)[self bundleIdentifierForHelper], flag);

  if (success) {
    NSLog(@"[registerSchedulerWithSystem] succesfully %@ scheduler", (flag ? @"registered" : @"unregistered"));
    [self setScheduleEnabled:flag];
  }
  else {
    NSLog(@"[registerSchedulerWithSystem] failed to %@ scheduler", (flag ? @"register" : @"unregister"));
    [self setScheduleEnabled:!flag];
  }

  return success;
}

-(IBAction)toggleScheduler:(id)sender {

  NSInteger clickedSegment = [sender selectedSegment];

  BOOL shouldSetSchedulerActive = (clickedSegment == 1);

  NSLog(@"[toggleLaunchAtLogin:%@]", (shouldSetSchedulerActive ? @"YES" : @"NO"));

  if (![self registerSchedulerWithSystem:shouldSetSchedulerActive]) {

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"An error ocurred"];
    [alert addButtonWithTitle:@"OK"];
    [alert setInformativeText:[self errorForSchedulerRegistration:shouldSetSchedulerActive]];

    [alert runModal];
  }
}

@end
