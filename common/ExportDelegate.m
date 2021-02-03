//
//  ExportDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import "ExportDelegate.h"

#import <iTunesLibrary/ITLibrary.h>

#import "Defines.h"
#import "UserDefaultsExportConfiguration.h"
#import "LibrarySerializer.h"

@implementation ExportDelegate


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  _librarySerializer = [[LibrarySerializer alloc] init];

  [self loadPropertiesFromUserDefaults];

  return self;
}

- (instancetype)initWithConfiguration:(UserDefaultsExportConfiguration*)exportConfig {

  self = [self init];

  [self setConfiguration:exportConfig];

  return self;
}


#pragma mark - Accessors -

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

  // read user defaults
  _lastExportedAt = [groupDefaults valueForKey:@"LastExportedAt"];
}

- (void)setLastExportedAt:(nullable NSDate*)timestamp {

  NSLog(@"[setLastExportedAt %@]", timestamp.description);

  _lastExportedAt = timestamp;

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [groupDefaults setValue:_lastExportedAt forKey:@"LastExportedAt"];
}

- (BOOL)exportLibrary {

  // FIXME: use bookmarked output dir
  if (!_configuration.isOutputDirectoryValid) {
    NSLog(@"[exportLibrary] error - invalid output directory url");
    return NO;
  }

  if (!_configuration.isOutputFileNameValid) {
    NSLog(@"[exportLibrary] error - invalid output filename");
    return NO;
  }

  [_librarySerializer setConfiguration:_configuration];

  NSError *initLibraryError = nil;
  ITLibrary *itLibrary = [ITLibrary libraryWithAPIVersion:@"1.1" error:&initLibraryError];
  if (!itLibrary) {
    NSLog(@"[exportLibrary]  error - failed to init ITLibrary. error: %@", initLibraryError.localizedDescription);
    return NO;
  }

  // ensure url renewal status is current
  NSURL* outputDirectoryUrl = _configuration.resolveAndAutoRenewOutputDirectoryUrl;
  if (!outputDirectoryUrl) {
    NSLog(@"[exportLibrary] unable to retrieve output directory - a directory must be selected to obtain write permission");
    return NO;
  }
  NSLog(@"[exportLibrary] saving to: %@", outputDirectoryUrl);

  // serialize library
  NSLog(@"[exportLibrary] serializing library");
  [_librarySerializer serializeLibrary:itLibrary];

  // write library
  NSLog(@"[exportLibrary] writing library to file");
  [outputDirectoryUrl startAccessingSecurityScopedResource];
  BOOL writeSuccess = [_librarySerializer writeDictionary];
  [outputDirectoryUrl stopAccessingSecurityScopedResource];

  if (writeSuccess) {
    [self setLastExportedAt:[NSDate date]];
    return YES;
  }
  else {
    return NO;
  }
}


@end
