//
//  HelperAppManager.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "HelperAppManager.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Logger.h"
#import "Defines.h"


@implementation HelperAppManager


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (BOOL)isHelperRegisteredWithSystem {

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

      if ([__MLE__HelperBundleIdentifier isEqualToString:[jobDict objectForKey:@"Label"]]) {
        return [[jobDict objectForKey:@"OnDemand"] boolValue];
      }
    }
  }

  return NO;
}

- (NSString*)errorForHelperRegistration:(BOOL)registerFlag {

  if (registerFlag) {
    return @"Couldn't add Music Library Exporter Helper to launch at login item list.";
  }
  else {
    return @"Couldn't remove Music Library Exporter Helper from launch at login item list.";
  }
}


#pragma mark - Mutators

- (BOOL)registerHelperWithSystem:(BOOL)flag {

  MLE_Log_Info(@"HelperAppManager [registerHelperWithSystem:%@]", (flag ? @"YES" : @"NO"));

  BOOL success = SMLoginItemSetEnabled ((__bridge CFStringRef)__MLE__HelperBundleIdentifier, flag);

  if (success) {
    MLE_Log_Info(@"HelperAppManager [registerHelperWithSystem] succesfully %@ helper", (flag ? @"registered" : @"unregistered"));
  }
  else {
    MLE_Log_Info(@"HelperAppManager [registerHelperWithSystem] failed to %@ helper", (flag ? @"register" : @"unregister"));
  }

  return success;
}

- (void)updateHelperRegistrationWithScheduleEnabled:(BOOL)scheduleEnabled {

#if HELPER_REGISTRATION_ENABLED == 1
  MLE_Log_Info(@"HelperAppManager [updateHelperRegistrationWithScheduleEnabled:%@]", (scheduleEnabled ? @"YES" : @"NO"));

  BOOL shouldUpdate = (scheduleEnabled != [self isHelperRegisteredWithSystem]);
  if (shouldUpdate) {
    MLE_Log_Info(@"HelperAppManager [updateHelperRegistrationIfRequired] updating registration to: %@", (scheduleEnabled ? @"registered" : @"unregistered"));
    [self registerHelperWithSystem:scheduleEnabled];
  }
#endif
}

@end
