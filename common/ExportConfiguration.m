//
//  ExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ExportConfiguration.h"


static NSString* const _appGroupIdentifier = @"group.9YLM7HTV6V.com.MusicLibraryExporter";


@implementation ExportConfiguration {

  NSUserDefaults* _userDefaults;
}

- (instancetype)init {

  return [self initWithUserDefaults];
}

- (instancetype)initWithUserDefaults {

  self = [super init];

  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
  NSAssert(_userDefaults, @"failed to init NSUSerDefaults for app group");

  [self setValuesFromUserDefaults];

  return self;
}

- (NSString*)ouputDirectoryPath {

  return _outputDirectoryPath;
}

- (NSString*)ouputFileName {

  return _outputFileName;
}

- (NSString*)outputFilePath {

  if (_outputDirectoryPath.length == 0 || _outputFileName.length == 0) {
    return nil;
  }

  return [[_outputDirectoryPath stringByAppendingString:@"/"] stringByAppendingString:_outputFileName];
}

- (BOOL)remapRootDirectory {

  return _remapRootDirectory;
}

- (NSString*)remapRootDirectoryOriginalPath {

  return _remapRootDirectoryOriginalPath;
}

- (NSString*)remapRootDirectoryMappedPath {

  return _remapRootDirectoryMappedPath;
}

- (BOOL)scheduleEnabled {

  return _scheduleEnabled;
}

- (void)setOutputDirectoryPath:(NSString*)path {

  NSLog(@"[setOutputDirectoryPath %@]", path);

  _outputDirectoryPath = path;
  [_userDefaults setValue:_outputDirectoryPath forKey:@"OutputDirectoryPath"];
}

- (void)setOutputFileName:(NSString*)fileName {

  NSLog(@"[setOutputFileName %@]", fileName);

  _outputFileName = fileName;
  [_userDefaults setValue:_outputFileName forKey:@"OutputFileName"];
}

- (void)setRemapRootDirectory:(BOOL)flag {

  NSLog(@"[setRemapRootDirectory %@]", (flag ? @"YES" : @"NO"));

  _remapRootDirectory = flag;
  [_userDefaults setBool:_remapRootDirectory forKey:@"RemapRootDirectory"];
}

- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath {

  NSLog(@"[setRemapRootDirectoryOriginalPath %@]", originalPath);

  _remapRootDirectoryOriginalPath = originalPath;
  [_userDefaults setValue:_remapRootDirectoryOriginalPath forKey:@"RemapRootDirectoryOriginalPath"];
}

- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath {

  NSLog(@"[setRemapRootDirectoryMappedPath %@]", mappedPath);

  _remapRootDirectoryMappedPath = mappedPath;
  [_userDefaults setValue:_remapRootDirectoryMappedPath forKey:@"RemapRootDirectoryMappedPath"];
}

- (void)setScheduleEnabled:(BOOL)flag {

  NSLog(@"[setScheduleEnabled %@]", (flag ? @"YES" : @"NO"));

  _scheduleEnabled = flag;
  [_userDefaults setBool:_scheduleEnabled forKey:@"ScheduleEnabled"];
}

- (void)setValuesFromUserDefaults {

  NSLog(@"[setValuesFromUserDefaults]");

  _outputDirectoryPath = [_userDefaults valueForKey:@"OutputDirectoryPath"];
  _outputFileName = [_userDefaults valueForKey:@"OutputFileName"];

  _remapRootDirectory = [_userDefaults boolForKey:@"RemapRootDirectory"];
  _remapRootDirectoryOriginalPath = [_userDefaults valueForKey:@"RemapRootDirectoryOriginalPath"];
  _remapRootDirectoryMappedPath = [_userDefaults valueForKey:@"RemapRootDirectoryMappedPath"];
}

@end
