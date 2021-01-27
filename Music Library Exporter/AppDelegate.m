//
//  AppDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import "AppDelegate.h"

#import <ServiceManagement/ServiceManagement.h>


static NSString* const _appGroupIdentifier = @"group.9YLM7HTV6V.com.MusicLibraryExporter";
static NSString* const _helperBundleIdentifier = @"com.kylekingcdn.MusicLibraryExporter.MusicLibraryExporterHelper";


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end


@implementation AppDelegate


@synthesize launchAtLoginButton;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  _scheduleEnabled = [self isScheduleRegisteredWithSystem];
  
  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  if (groupDefaults) {

  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

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

// source: http://blog.mcohen.me/2012/01/12/login-items-in-the-sandbox/
-(BOOL)isScheduleRegisteredWithSystem {

// > As of WWDC 2017, Apple engineers have stated that [SMCopyAllJobDictionaries] is still the preferred API to use.
//     ref: https://github.com/alexzielenski/StartAtLoginController/issues/12#issuecomment-307525807

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  CFArrayRef cfJobDictsArr = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
#pragma pop
  NSArray* jobDictsArr = CFBridgingRelease(cfJobDictsArr);

  if (jobDictsArr && jobDictsArr.count > 0) {

    for (NSDictionary* jobDict in jobDictsArr) {

      if ([_helperBundleIdentifier isEqualToString:[jobDict objectForKey:@"Label"]]) {
        return [[jobDict objectForKey:@"OnDemand"] boolValue];
      }
    }
  }

  return NO;
}

-(BOOL)registerSchedulerWithSystem:(BOOL)flag {

  NSLog(@"[registerSchedulerWithSystem:%@]", (flag ? @"YES" : @"NO"));

  BOOL success = SMLoginItemSetEnabled ((__bridge CFStringRef)_helperBundleIdentifier, flag);

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

  NSControlStateValue buttonState = [sender state];

  BOOL shouldSetSchedulerActive = (buttonState == NSControlStateValueOn);

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
