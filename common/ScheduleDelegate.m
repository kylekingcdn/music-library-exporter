//
//  ScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Defines.h"
#import "ScheduleConfiguration.h"
#import "ExportDelegate.h"

@implementation ScheduleDelegate {

  ExportDelegate* _exportDelegate;

  NSBackgroundActivityScheduler* _scheduler;
}


#pragma mark - Initializers -

- (instancetype)initWithConfiguration:(ScheduleConfiguration*)config andExportDelegate:(ExportDelegate*)exportDelegate {

  self = [super init];

  _configuration = config;
  _exportDelegate = exportDelegate;

  [self updateHelperRegistrationIfRequired];

  return self;
}


#pragma mark - Accessors -

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


#pragma mark - Mutators -

- (BOOL)registerHelperWithSystem:(BOOL)flag {

  NSLog(@"[registerHelperWithSystem:%@]", (flag ? @"YES" : @"NO"));

  BOOL success = SMLoginItemSetEnabled ((__bridge CFStringRef)__MLE__HelperBundleIdentifier, flag);

  if (success) {
    NSLog(@"[registerHelperWithSystem] succesfully %@ helper", (flag ? @"registered" : @"unregistered"));
  }
  else {
    NSLog(@"[registerHelperWithSystem] failed to %@ helper", (flag ? @"register" : @"unregister"));
  }

  return success;
}

- (void)updateHelperRegistrationIfRequired {

  NSLog(@"[updateHelperRegistrationIfRequired]");

  BOOL shouldUpdate = (_configuration.scheduleEnabled != [self isHelperRegisteredWithSystem]);
  if (shouldUpdate) {
    NSLog(@"[updateHelperRegistrationIfRequired] updating registration to: %@", (_configuration.scheduleEnabled ? @"registered" : @"unregistered"));
    [self registerHelperWithSystem:_configuration.scheduleEnabled];
  }
}

- (void)activateScheduler {

  NSLog(@"ScheduleDelegate [activateScheduler]");

  _scheduler = [[NSBackgroundActivityScheduler alloc] initWithIdentifier:[__MLE__HelperBundleIdentifier stringByAppendingString:@".scheduler"]];

  [_scheduler setRepeats:YES];
  [_scheduler setTolerance:60];
  [_scheduler setInterval:(_configuration.scheduleInterval * 60 * 60)];
  [_scheduler setQualityOfService:NSQualityOfServiceUtility];

  [_scheduler scheduleWithBlock:^(NSBackgroundActivityCompletionHandler completion) {

    NSLog(@"ScheduleDelegate [activateScheduler] starting task (%@)", [[NSDate date] description]);

    [self->_exportDelegate exportLibrary];
    
    completion(NSBackgroundActivityResultFinished);
  }];
}

- (void)deactivateScheduler {

  NSLog(@"ScheduleDelegate [deactivateScheduler]");

  [_scheduler invalidate];
}

@end
