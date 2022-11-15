//
//  ScheduleConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleConfiguration.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Logger.h"
#import "Defines.h"

@implementation ScheduleConfiguration {

  NSUserDefaults* _userDefaults;

  BOOL _scheduleEnabled;
  NSTimeInterval _scheduleInterval;

  NSDate* _lastExportedAt;
  NSDate* _nextExportAt;

  BOOL _skipOnBattery;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @NO,             ScheduleConfigurationKeyScheduleEnabled,
    @3600,              ScheduleConfigurationKeyScheduleInterval,
//    nil,             ScheduleConfigurationKeyLastExportedAt,
//    nil,             ScheduleConfigurationKeyNextExportAt,
    @NO,             ScheduleConfigurationKeySkipOnBattery,
    nil
  ];
}

- (BOOL)scheduleEnabled {

  return _scheduleEnabled;
}

- (NSTimeInterval)scheduleInterval {

  return _scheduleInterval;
}

- (nullable NSDate*)lastExportedAt {

  return _lastExportedAt;
}

- (nullable NSDate*)nextExportAt {

  return _nextExportAt;
}

- (BOOL)skipOnBattery {

  return _skipOnBattery;
}

- (void)dumpProperties {

  MLE_Log_Info(@"ScheduleConfiguration [dumpProperties]");

  MLE_Log_Info(@"  ScheduleEnabled:                 '%@'", (_scheduleEnabled ? @"YES" : @"NO"));
  MLE_Log_Info(@"  ScheduleInterval:                '%f'", _scheduleInterval);
  MLE_Log_Info(@"  LastExportedAt:                  '%@'", _lastExportedAt.description);
  MLE_Log_Info(@"  NextExportAt:                    '%@'", _nextExportAt.description);
  MLE_Log_Info(@"  SkipOnBattery:                   '%@'", (_skipOnBattery ? @"YES" : @"NO"));
}


#pragma mark - Mutators

- (void)loadPropertiesFromUserDefaults {

  // register default values for properties
  [_userDefaults registerDefaults:[self defaultValues]];

  // read user defaults
  _scheduleEnabled = [_userDefaults boolForKey:ScheduleConfigurationKeyScheduleEnabled];
  _scheduleInterval = [_userDefaults doubleForKey:ScheduleConfigurationKeyScheduleInterval];

  _lastExportedAt = [_userDefaults valueForKey:ScheduleConfigurationKeyLastExportedAt];
  _nextExportAt = [_userDefaults valueForKey:ScheduleConfigurationKeyNextExportAt];

  _skipOnBattery = [_userDefaults boolForKey:ScheduleConfigurationKeySkipOnBattery];
}

- (void)setScheduleEnabled:(BOOL)flag {

  MLE_Log_Info(@"ScheduleConfiguration [setScheduleEnabled:%@]", (flag ? @"YES" : @"NO"));

  _scheduleEnabled = flag;

  [_userDefaults setBool:_scheduleEnabled forKey:ScheduleConfigurationKeyScheduleEnabled];
}

- (void)setScheduleInterval:(NSTimeInterval)interval {

  MLE_Log_Info(@"ScheduleConfiguration [setScheduleInterval:%ld]", (long)interval);

  if (_scheduleInterval != interval) {
    
    _scheduleInterval = interval;

    [_userDefaults setDouble:_scheduleInterval forKey:ScheduleConfigurationKeyScheduleInterval];
  }
}

- (void)setLastExportedAt:(nullable NSDate*)timestamp {

  MLE_Log_Info(@"ScheduleConfiguration [setLastExportedAt:%@]", timestamp.description);

  if (_lastExportedAt != timestamp) {

    _lastExportedAt = timestamp;

    [_userDefaults setValue:_lastExportedAt forKey:ScheduleConfigurationKeyLastExportedAt];
  }
}

- (void)setNextExportAt:(nullable NSDate*)timestamp {

  MLE_Log_Info(@"ScheduleConfiguration [setNextExportAt:%@]", timestamp.description);

  if (_nextExportAt != timestamp) {

    _nextExportAt = timestamp;

    [_userDefaults setValue:_nextExportAt forKey:ScheduleConfigurationKeyNextExportAt];
  }
}

- (void)setSkipOnBattery:(BOOL)flag {

  MLE_Log_Info(@"ScheduleConfiguration [setSkipOnBattery:%@]", (flag ? @"YES" : @"NO"));

  _skipOnBattery = flag;

  [_userDefaults setBool:_skipOnBattery forKey:ScheduleConfigurationKeySkipOnBattery];
}

@end

NSString* const ScheduleConfigurationKeyScheduleEnabled = @"ScheduleEnabled";
NSString* const ScheduleConfigurationKeyScheduleInterval = @"ScheduleInterval";
NSString* const ScheduleConfigurationKeyLastExportedAt = @"LastExportedAt";
NSString* const ScheduleConfigurationKeyNextExportAt = @"NextExportAt";
NSString* const ScheduleConfigurationKeySkipOnBattery = @"SkipOnBattery";
