//
//  ExportDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import "ExportDelegate.h"

#import "Defines.h"


@implementation ExportDelegate


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  [self loadPropertiesFromUserDefaults];

  return self;
}


#pragma mark - Accessors -

/*
- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"",             @"LastExportedAt", // we want this to be nil if it doesn't exist
    nil
  ];
}
*/

- (NSDate*)lastExportedAt {

  return _lastExportedAt;
}

- (void)dumpProperties {

  NSLog(@"ExportDelegate [dumpProperties]");

  NSLog(@"  LastExportedAt:                  '%@'", _lastExportedAt.description);
}


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults {

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  // register default values for properties
//  [groupDefaults registerDefaults:[self defaultValues]];

  // read user defaults
  _lastExportedAt = [groupDefaults valueForKey:@"LastExportedAt"];
}

- (void)setLastExportedAt:(nullable NSDate*)timestamp {

  NSLog(@"[setLastExportedAt %@]", timestamp.description);

  _lastExportedAt = timestamp;

  // FIXME: should defaults be a member var?
  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  [groupDefaults setValue:_lastExportedAt forKey:@"LastExportedAt"];
}


@end
