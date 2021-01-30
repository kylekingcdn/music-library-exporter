//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import <ServiceManagement/ServiceManagement.h>


static NSString* const _appGroupIdentifier = @"group.9YLM7HTV6V.com.MusicLibraryExporter";
static NSString* const _helperBundleIdentifier = @"com.kylekingcdn.MusicLibraryExporter.MusicLibraryExporterHelper";


@interface ConfigurationViewController ()

@end


@implementation ConfigurationViewController

- (id)init {
    return (self = [super initWithNibName: @"ConfigurationView" bundle: nil]);
}

- (void)viewDidLoad {

  [super viewDidLoad];

  _scheduleEnabled = [self isScheduleRegisteredWithSystem];

  NSLog(@"[viewDidLoad] isScheduleRegisteredWithSystem: %@", (_scheduleEnabled ? @"YES" : @"NO"));

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  if (groupDefaults) {
    [scheduleEnabledCheckBox setState:(_scheduleEnabled ? NSControlStateValueOn : NSControlStateValueOff)];
  }
}

- (BOOL)isScheduleRegisteredWithSystem {

  // source: http://blog.mcohen.me/2012/01/12/login-items-in-the-sandbox/
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

- (BOOL)registerSchedulerWithSystem:(BOOL)flag {

  NSLog(@"[registerSchedulerWithSystem:%@]", (flag ? @"YES" : @"NO"));

  BOOL success = SMLoginItemSetEnabled ((__bridge CFStringRef)_helperBundleIdentifier, flag);

  if (success) {
    NSLog(@"[registerSchedulerWithSystem] succesfully %@ scheduler", (flag ? @"registered" : @"unregistered"));
    _scheduleEnabled = YES;
  }
  else {
    NSLog(@"[registerSchedulerWithSystem] failed to %@ scheduler", (flag ? @"register" : @"unregister"));
    _scheduleEnabled = YES;
  }

  return success;
}

- (IBAction)setScheduleEnabled:(id)sender {

  NSControlStateValue buttonState = [sender state];
  BOOL shouldSetSchedulerActive = (buttonState == NSControlStateValueOn);

  NSLog(@"[setScheduleEnabled:%@]", (shouldSetSchedulerActive ? @"YES" : @"NO"));

  if (![self registerSchedulerWithSystem:shouldSetSchedulerActive]) {

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"An error ocurred"];
    [alert addButtonWithTitle:@"OK"];
    [alert setInformativeText:[self errorForSchedulerRegistration:shouldSetSchedulerActive]];

    [alert runModal];
  }
}

- (NSString*)errorForSchedulerRegistration:(BOOL)registerFlag {

  if (registerFlag) {
    return @"Couldn't add Music Library Exporter Helper to launch at login item list.";
  }
  else {
    return @"Couldn't remove Music Library Exporter Helper from launch at login item list.";
  }
}

@end
