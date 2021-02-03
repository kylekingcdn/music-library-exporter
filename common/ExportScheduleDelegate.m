//
//  ExportScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ExportScheduleDelegate.h"

#import "Defines.h"

@implementation ExportScheduleDelegate


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

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


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults {

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  // register default values for properties
  [groupDefaults registerDefaults:[self defaultValues]];

  // read user defaults
  [self setScheduleEnabled:[groupDefaults boolForKey:@"ScheduleEnabled"]];
  [self setScheduleInterval:[groupDefaults integerForKey:@"ScheduleInterval"]];

}

@end
