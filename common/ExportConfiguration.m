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


#pragma mark - Constructors -

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


#pragma mark - Accessors -

- (NSString*)musicLibraryPath {

    return _musicLibraryPath;
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

- (BOOL)flattenPlaylistHierarchy {

    return _flattenPlaylistHierarchy;
}

- (BOOL)includeInternalPlaylists {

    return _includeInternalPlaylists;
}

- (NSArray<NSString*>*)excludedPlaylistPersistentIds {

    return _excludedPlaylistPersistentIds;
}

- (BOOL)scheduleEnabled {

  return _scheduleEnabled;
}

- (NSInteger)scheduleInterval {

    return _scheduleInterval;
}

- (NSDate*)lastExport {

    return _lastExport;
}


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  NSLog(@"[setMusicLibraryPath %@]", musicLibraryPath);

  _musicLibraryPath = musicLibraryPath;
  [_userDefaults setValue:_musicLibraryPath forKey:@"MusicLibraryPath"];
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

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  NSLog(@"[setFlattenPlaylistHierarchy %@]", (flag ? @"YES" : @"NO"));

  _flattenPlaylistHierarchy = flag;
  [_userDefaults setBool:_flattenPlaylistHierarchy forKey:@"FlattenPlaylistHierarchy"];
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  NSLog(@"[setIncludeInternalPlaylists %@]", (flag ? @"YES" : @"NO"));

  _includeInternalPlaylists = flag;
  [_userDefaults setBool:_includeInternalPlaylists forKey:@"IncludeInternalPlaylists"];
}

- (void)setExcludedPlaylistPersistentIds:(NSArray<NSString*>*)excludedIds {

  NSLog(@"[setExcludedPlaylistPersistentIds %lu]", (unsigned long)excludedIds.count);

  _excludedPlaylistPersistentIds = excludedIds;
  [_userDefaults setValue:_excludedPlaylistPersistentIds forKey:@"ExcludedPlaylistPersistentIds"];
}

- (void)setScheduleEnabled:(BOOL)flag {

  NSLog(@"[setScheduleEnabled %@]", (flag ? @"YES" : @"NO"));

  _scheduleEnabled = flag;
  [_userDefaults setBool:_scheduleEnabled forKey:@"ScheduleEnabled"];
}

- (void)setScheduleInterval:(NSInteger)interval {

  NSLog(@"[setScheduleInterval %ld]", (long)interval);

  _scheduleInterval = interval;
  [_userDefaults setInteger:_scheduleInterval forKey:@"ScheduleInterval"];
}

- (void)setLastExport:(NSDate*)lastExport {

  NSLog(@"[setLastExport %@]", lastExport);

  _lastExport = lastExport;
  [_userDefaults setValue:_lastExport forKey:@"LastExport"];
}

- (void)setValuesFromUserDefaults {

  NSLog(@"[setValuesFromUserDefaults]");

  _musicLibraryPath = [_userDefaults valueForKey:@"MusicLibraryPath"];

  _outputDirectoryPath = [_userDefaults valueForKey:@"OutputDirectoryPath"];
  _outputFileName = [_userDefaults valueForKey:@"OutputFileName"];

  _remapRootDirectory = [_userDefaults boolForKey:@"RemapRootDirectory"];
  _remapRootDirectoryOriginalPath = [_userDefaults valueForKey:@"RemapRootDirectoryOriginalPath"];
  _remapRootDirectoryMappedPath = [_userDefaults valueForKey:@"RemapRootDirectoryMappedPath"];

  _flattenPlaylistHierarchy = [_userDefaults boolForKey:@"FlattenPlaylistHierarchy"];
  _includeInternalPlaylists = [_userDefaults boolForKey:@"IncludeInternalPlaylists"];
  _excludedPlaylistPersistentIds = [_userDefaults valueForKey:@"ExcludedPlaylistPersistentIds"];

  _scheduleEnabled = [_userDefaults boolForKey:@"ScheduleEnabled"];
  _scheduleInterval = [_userDefaults integerForKey:@"ScheduleInterval"];

  _lastExport = [_userDefaults valueForKey:@"LastExport"];
}

@end
