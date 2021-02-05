//
//  ExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ExportConfiguration.h"


@implementation ExportConfiguration {

  NSString* _musicLibraryPath;

  NSURL* _outputDirectoryUrl;
  NSString* _outputFileName;

  BOOL _remapRootDirectory;
  NSString* _remapRootDirectoryOriginalPath;
  NSString* _remapRootDirectoryMappedPath;

  BOOL _flattenPlaylistHierarchy;
  BOOL _includeInternalPlaylists;
  NSArray<NSNumber*>* _excludedPlaylistPersistentIds;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  return self;
}


#pragma mark - Accessors -

- (NSString*)musicLibraryPath {

    return _musicLibraryPath;
}

- (NSURL*)outputDirectoryUrl {

  return _outputDirectoryUrl;
}

- (NSString*)outputDirectoryPath {

  if (_outputDirectoryUrl && _outputDirectoryUrl.isFileURL) {
    return _outputDirectoryUrl.path;
  }
  else {
    return [NSString string];
  }
}

- (BOOL)isOutputDirectoryValid {

  return _outputDirectoryUrl && _outputDirectoryUrl.isFileURL;
}

- (NSString*)outputFileName {

  return _outputFileName;
}

- (BOOL)isOutputFileNameValid {

  return _outputFileName.length > 0;
}

- (NSURL*)outputFileUrl {

  // check if output directory is valid path
  if (_outputDirectoryUrl && _outputDirectoryUrl.isFileURL) {

    // check if output file name has been set
    if (_outputFileName.length > 0) {
      return [_outputDirectoryUrl URLByAppendingPathComponent:_outputFileName];
    }
  }

  return nil;
}

- (NSString*)outputFilePath {

  NSURL* outputFileUrl = [self outputFileUrl];

  // check if output file url is valid
  if (outputFileUrl) {
    return outputFileUrl.path;
  }
  else {
    return [NSString string];
  }
}

- (BOOL)isOutputFilePathValid {

  return [self isOutputDirectoryValid] && [self isOutputFileNameValid];
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

- (NSArray<NSNumber*>*)excludedPlaylistPersistentIds {

    return _excludedPlaylistPersistentIds;
}

- (void)dumpProperties {

  NSLog(@"ExportConfiguration [dumpProperties]");

  NSLog(@"  MusicLibraryPath:                '%@'", _musicLibraryPath);

  NSLog(@"  OutputDirectoryUrl:              '%@'", _outputDirectoryUrl);
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

  NSLog(@"ExportConfiguration [setMusicLibraryPath %@]", musicLibraryPath);

  _musicLibraryPath = musicLibraryPath;
}

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl {

  NSLog(@"ExportConfiguration [setOutputDirectoryUrl %@]", dirUrl);

  _outputDirectoryUrl = dirUrl;
}

- (void)setOutputFileName:(NSString*)fileName {

  NSLog(@"ExportConfiguration [setOutputFileName %@]", fileName);

  _outputFileName = fileName;
}

- (void)setRemapRootDirectory:(BOOL)flag {

  NSLog(@"ExportConfiguration [setRemapRootDirectory %@]", (flag ? @"YES" : @"NO"));

  _remapRootDirectory = flag;
}

- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath {

  NSLog(@"ExportConfiguration [setRemapRootDirectoryOriginalPath %@]", originalPath);

  _remapRootDirectoryOriginalPath = originalPath;
}

- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath {

  NSLog(@"ExportConfiguration [setRemapRootDirectoryMappedPath %@]", mappedPath);

  _remapRootDirectoryMappedPath = mappedPath;
}

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  NSLog(@"ExportConfiguration [setFlattenPlaylistHierarchy %@]", (flag ? @"YES" : @"NO"));

  _flattenPlaylistHierarchy = flag;
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  NSLog(@"ExportConfiguration [setIncludeInternalPlaylists %@]", (flag ? @"YES" : @"NO"));

  _includeInternalPlaylists = flag;
}

- (void)setExcludedPlaylistPersistentIds:(NSArray<NSNumber*>*)excludedIds {

  NSLog(@"ExportConfiguration [setExcludedPlaylistPersistentIds %lu]", (unsigned long)excludedIds.count);

  _excludedPlaylistPersistentIds = excludedIds;
}

@end
