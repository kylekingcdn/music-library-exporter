//
//  ScheduleConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleConfiguration.h"

#import <ServiceManagement/ServiceManagement.h>

#import "Defines.h"


@implementation ScheduleConfiguration {

  NSUserDefaults* _userDefaults;

  BOOL _scheduleEnabled;
  NSInteger _scheduleInterval;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

  [self loadPropertiesFromUserDefaults];

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

- (void)dumpProperties {

  NSLog(@"ScheduleConfiguration [dumpProperties]");

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
}

- (void)setScheduleInterval:(NSInteger)interval {

  NSLog(@"[setScheduleInterval:%ld]", (long)interval);

  _scheduleInterval = interval;

  [_userDefaults setInteger:_scheduleInterval forKey:@"ScheduleInterval"];
}

@end
