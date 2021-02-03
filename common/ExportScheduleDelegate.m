//
//  ExportScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ExportScheduleDelegate.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Defines.h"
#import "ExportDelegate.h"


@implementation ExportScheduleDelegate {

  NSUserDefaults* _userDefaults;

  ExportDelegate* _exportDelegate;
  NSBackgroundActivityScheduler* _scheduler;
}


#pragma mark - Initializers -

- (instancetype)initWithExportDelegate:(ExportDelegate*)exportDelegate {

  self = [super init];

  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

  _exportDelegate = exportDelegate;
  
  [self loadPropertiesFromUserDefaults];
  [self updateHelperRegistrationIfRequired];

  return self;
}


#pragma mark - Accessors -

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @NO,             @"ScheduleEnabled",
    @1,              @"ScheduleInterval",
    nil
  ];
}

- (BOOL)scheduleEnabled {

  return _scheduleEnabled;
}

- (NSInteger)scheduleInterval {

  return _scheduleInterval;
}

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

- (void)dumpProperties {

  NSLog(@"ExportScheduleDelegate [dumpProperties]");

  NSLog(@"  ScheduleEnabled:                 '%@'", (_scheduleEnabled ? @"YES" : @"NO"));
  NSLog(@"  ScheduleInterval:                '%ld'", (long)_scheduleInterval);
}


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults {

  // register default values for properties
  [_userDefaults registerDefaults:[self defaultValues]];

  // read user defaults
  _scheduleEnabled = [_userDefaults boolForKey:@"ScheduleEnabled"];
  _scheduleInterval = [_userDefaults integerForKey:@"ScheduleInterval"];
}

- (void)setScheduleEnabled:(BOOL)flag {

  NSLog(@"[setScheduleEnabled:%@]", (flag ? @"YES" : @"NO"));

  _scheduleEnabled = flag;

  [_userDefaults setBool:_scheduleEnabled forKey:@"ScheduleEnabled"];

  // update scheduler registration
  [self registerHelperWithSystem:_scheduleEnabled];
}

- (void)setScheduleInterval:(NSInteger)interval {

  NSLog(@"[setScheduleInterval:%ld]", (long)interval);

  _scheduleInterval = interval;

  [_userDefaults setInteger:_scheduleInterval forKey:@"ScheduleInterval"];
}

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

  BOOL shouldUpdate = (_scheduleEnabled != [self isHelperRegisteredWithSystem]);
  if (shouldUpdate) {
    NSLog(@"[updateHelperRegistrationIfRequired] updating registration to: %@", (_scheduleEnabled ? @"registered" : @"unregistered"));
    [self registerHelperWithSystem:_scheduleEnabled];
  }
}

- (void)activateScheduler {

  NSLog(@"ExportScheduleDelegate [activateScheduler]");

  _scheduler = [[NSBackgroundActivityScheduler alloc] initWithIdentifier:[__MLE__HelperBundleIdentifier stringByAppendingString:@".scheduler"]];

  [_scheduler setRepeats:YES];
  [_scheduler setTolerance:60];
  [_scheduler setInterval:(_scheduleInterval * 60 * 60)];
  [_scheduler setQualityOfService:NSQualityOfServiceUtility];

  [_scheduler scheduleWithBlock:^(NSBackgroundActivityCompletionHandler completion) {

    NSLog(@"ExportScheduleDelegate [activateScheduler] starting task (%@)", [[NSDate date] description]);

    [self->_exportDelegate exportLibrary];
    
    completion(NSBackgroundActivityResultFinished);
  }];
}

- (void)deactivateScheduler {

  NSLog(@"ExportScheduleDelegate [deactivateScheduler]");

  [_scheduler invalidate];
}

@end
