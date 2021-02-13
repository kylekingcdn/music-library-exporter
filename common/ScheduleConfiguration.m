//
//  ScheduleConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleConfiguration.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Defines.h"


static ScheduleConfiguration* _sharedConfig;


@implementation ScheduleConfiguration {

  NSUserDefaults* _userDefaults;

  BOOL _scheduleEnabled;
  NSTimeInterval _scheduleInterval;

  NSDate* _lastExportedAt;
  NSDate* _nextExportAt;

  BOOL _skipOnBattery;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

  [self loadPropertiesFromUserDefaults];

  return self;
}


#pragma mark - Accessors -

+ (ScheduleConfiguration*)sharedConfig {

  NSAssert((_sharedConfig != nil), @"ScheduleConfiguration sharedConfig has not been initialized!");

  return _sharedConfig;
}

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @NO,             @"ScheduleEnabled",
    @3600,              @"ScheduleInterval",
//    nil,             @"LastExportedAt",
//    nil,             @"NextExportAt",
    @NO,             @"SkipOnBattery",
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

  NSLog(@"ScheduleConfiguration [dumpProperties]");

  NSLog(@"  ScheduleEnabled:                 '%@'", (_scheduleEnabled ? @"YES" : @"NO"));
  NSLog(@"  ScheduleInterval:                '%f'", _scheduleInterval);
  NSLog(@"  LastExportedAt:                  '%@'", _lastExportedAt.description);
  NSLog(@"  NextExportAt:                    '%@'", _nextExportAt.description);
  NSLog(@"  SkipOnBattery:                   '%@'", (_skipOnBattery ? @"YES" : @"NO"));
}


#pragma mark - Mutators -

+ (void)initSharedConfig:(ScheduleConfiguration*)sharedConfig {

  NSAssert((_sharedConfig == nil), @"ScheduleConfiguration sharedConfig has already been initialized!");

  _sharedConfig = sharedConfig;
}

- (void)loadPropertiesFromUserDefaults {

  // register default values for properties
  [_userDefaults registerDefaults:[self defaultValues]];

  // read user defaults
  _scheduleEnabled = [_userDefaults boolForKey:@"ScheduleEnabled"];
  _scheduleInterval = [_userDefaults doubleForKey:@"ScheduleInterval"];

  _lastExportedAt = [_userDefaults valueForKey:@"LastExportedAt"];
  _nextExportAt = [_userDefaults valueForKey:@"NextExportAt"];

  _skipOnBattery = [_userDefaults boolForKey:@"SkipOnBattery"];
}

- (void)setScheduleEnabled:(BOOL)flag {

  NSLog(@"ScheduleConfiguration [setScheduleEnabled:%@]", (flag ? @"YES" : @"NO"));

  _scheduleEnabled = flag;

  [_userDefaults setBool:_scheduleEnabled forKey:@"ScheduleEnabled"];
}

- (void)setScheduleInterval:(NSTimeInterval)interval {

  NSLog(@"ScheduleConfiguration [setScheduleInterval:%ld]", (long)interval);

  if (_scheduleInterval != interval) {
    
    _scheduleInterval = interval;

    [_userDefaults setDouble:_scheduleInterval forKey:@"ScheduleInterval"];
  }
}

- (void)setLastExportedAt:(nullable NSDate*)timestamp {

  NSLog(@"ScheduleConfiguration [setLastExportedAt:%@]", timestamp.description);

  if (_lastExportedAt != timestamp) {

    _lastExportedAt = timestamp;

    [_userDefaults setValue:_lastExportedAt forKey:@"LastExportedAt"];
  }
}

- (void)setNextExportAt:(nullable NSDate*)timestamp {

  NSLog(@"ScheduleConfiguration [setNextExportAt:%@]", timestamp.description);

  if (_nextExportAt != timestamp) {

    _nextExportAt = timestamp;

    [_userDefaults setValue:_nextExportAt forKey:@"NextExportAt"];
  }
}

- (void)setSkipOnBattery:(BOOL)flag {

  NSLog(@"ScheduleConfiguration [setSkipOnBattery:%@]", (flag ? @"YES" : @"NO"));

  _skipOnBattery = flag;

  [_userDefaults setBool:_skipOnBattery forKey:@"SkipOnBattery"];
}

@end
