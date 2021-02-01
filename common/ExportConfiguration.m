//
//  ExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ExportConfiguration.h"


@implementation ExportConfiguration

#pragma mark - Constructors -

- (instancetype)init {

  self = [super init];

  return self;
}


#pragma mark - Accessors -

- (NSString*)musicLibraryPath {

    return _musicLibraryPath;
}

- (NSString*)outputDirectoryPath {

  return _outputDirectoryPath;
}

- (NSString*)outputFileName {

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

- (void)dumpConfiguration {

  NSLog(@"[dumpConfiguration]");

  NSLog(@"  MusicLibraryPath:                '%@'", _musicLibraryPath);

  NSLog(@"  OutputDirectoryPath:             '%@'", _outputDirectoryPath);
  NSLog(@"  OutputFileName:                  '%@'", _outputFileName);

  NSLog(@"  RemapRootDirectory:              '%@'", (_remapRootDirectory ? @"YES" : @"NO"));
  NSLog(@"  RemapRootDirectoryOriginalPath:  '%@'", _remapRootDirectoryOriginalPath);
  NSLog(@"  RemapRootDirectoryMappedPath:    '%@'", _remapRootDirectoryMappedPath);

  NSLog(@"  FlattenPlaylistHierarchy:        '%@'", (_flattenPlaylistHierarchy ? @"YES" : @"NO"));
  NSLog(@"  IncludeInternalPlaylists:        '%@'", (_includeInternalPlaylists ? @"YES" : @"NO"));
  NSLog(@"  ExcludedPlaylistPersistentIds:   '%@'", _excludedPlaylistPersistentIds);
}


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  NSLog(@"[setMusicLibraryPath %@]", musicLibraryPath);

  _musicLibraryPath = musicLibraryPath;
}

- (void)setOutputDirectoryPath:(NSString*)path {

  NSLog(@"[setOutputDirectoryPath %@]", path);

  _outputDirectoryPath = path;
}

- (void)setOutputFileName:(NSString*)fileName {

  NSLog(@"[setOutputFileName %@]", fileName);

  _outputFileName = fileName;
}

- (void)setRemapRootDirectory:(BOOL)flag {

  NSLog(@"[setRemapRootDirectory %@]", (flag ? @"YES" : @"NO"));

  _remapRootDirectory = flag;
}

- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath {

  NSLog(@"[setRemapRootDirectoryOriginalPath %@]", originalPath);

  _remapRootDirectoryOriginalPath = originalPath;
}

- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath {

  NSLog(@"[setRemapRootDirectoryMappedPath %@]", mappedPath);

  _remapRootDirectoryMappedPath = mappedPath;
}

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  NSLog(@"[setFlattenPlaylistHierarchy %@]", (flag ? @"YES" : @"NO"));

  _flattenPlaylistHierarchy = flag;
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  NSLog(@"[setIncludeInternalPlaylists %@]", (flag ? @"YES" : @"NO"));

  _includeInternalPlaylists = flag;
}

- (void)setExcludedPlaylistPersistentIds:(NSArray<NSString*>*)excludedIds {

  NSLog(@"[setExcludedPlaylistPersistentIds %lu]", (unsigned long)excludedIds.count);

  _excludedPlaylistPersistentIds = excludedIds;
}

@end
