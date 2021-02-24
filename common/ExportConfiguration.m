//
//  ExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ExportConfiguration.h"

#import "Logger.h"
#import "Utils.h"


static ExportConfiguration* _sharedConfig;


@implementation ExportConfiguration {

  NSString* _musicLibraryPath;

  NSURL* _outputDirectoryUrl;
  NSString* _outputDirectoryPath;
  NSString* _outputFileName;

  BOOL _remapRootDirectory;
  NSString* _remapRootDirectoryOriginalPath;
  NSString* _remapRootDirectoryMappedPath;

  BOOL _flattenPlaylistHierarchy;
  BOOL _includeInternalPlaylists;
  NSMutableSet<NSNumber*>* _excludedPlaylistPersistentIds;

  NSDictionary* _playlistCustomSortColumnDict;
  NSDictionary* _playlistCustomSortOrderDict;
}


#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  _excludedPlaylistPersistentIds = [NSMutableSet set];

  _playlistCustomSortColumnDict = [NSDictionary dictionary];
  _playlistCustomSortOrderDict = [NSDictionary dictionary];

  return self;
}


#pragma mark - Accessors

+ (ExportConfiguration*)sharedConfig {

  NSAssert((_sharedConfig != nil), @"ExportConfiguration sharedConfig has not been initialized!");

  return _sharedConfig;
}

- (NSString*)musicLibraryPath {

    return _musicLibraryPath;
}

- (NSURL*)outputDirectoryUrl {

  return _outputDirectoryUrl;
}

- (NSString*)outputDirectoryPath {

  return _outputDirectoryPath;
}

- (NSString*)outputDirectoryUrlPath {

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

- (NSSet<NSNumber*>*)excludedPlaylistPersistentIds {

    return _excludedPlaylistPersistentIds;
}

- (BOOL)isPlaylistIdExcluded:(NSNumber*)playlistId {

  return [_excludedPlaylistPersistentIds containsObject:playlistId];
}

- (NSDictionary*)playlistCustomSortColumnDict {

  return _playlistCustomSortColumnDict;
}

- (NSDictionary*)playlistCustomSortOrderDict {

  return _playlistCustomSortOrderDict;
}

- (PlaylistSortColumnType)playlistCustomSortColumn:(NSNumber*)playlistId {

  NSString* sortColumnTitle = [_playlistCustomSortColumnDict valueForKey:[playlistId stringValue]];
  PlaylistSortColumnType sortColumn = [Utils playlistSortColumnForTitle:sortColumnTitle];

  return sortColumn;
}

- (PlaylistSortOrderType)playlistCustomSortOrder:(NSNumber*)playlistId {

  NSString* sortOrderTitle = [_playlistCustomSortOrderDict valueForKey:[playlistId stringValue]];
  PlaylistSortOrderType sortOrder = [Utils playlistSortOrderForTitle:sortOrderTitle];

  return sortOrder;
}

- (void)dumpProperties {

  MLE_Log_Info(@"ExportConfiguration [dumpProperties]");

  MLE_Log_Info(@"  MusicLibraryPath:                '%@'", _musicLibraryPath);

  MLE_Log_Info(@"  OutputDirectoryUrl:              '%@'", _outputDirectoryUrl);
  MLE_Log_Info(@"  OutputDirectoryPath:             '%@'", _outputDirectoryPath);
  MLE_Log_Info(@"  OutputFileName:                  '%@'", _outputFileName);

  MLE_Log_Info(@"  RemapRootDirectory:              '%@'", (_remapRootDirectory ? @"YES" : @"NO"));
  MLE_Log_Info(@"  RemapRootDirectoryOriginalPath:  '%@'", _remapRootDirectoryOriginalPath);
  MLE_Log_Info(@"  RemapRootDirectoryMappedPath:    '%@'", _remapRootDirectoryMappedPath);

  MLE_Log_Info(@"  FlattenPlaylistHierarchy:        '%@'", (_flattenPlaylistHierarchy ? @"YES" : @"NO"));
  MLE_Log_Info(@"  IncludeInternalPlaylists:        '%@'", (_includeInternalPlaylists ? @"YES" : @"NO"));
  MLE_Log_Info(@"  ExcludedPlaylistPersistentIds:   '%@'", _excludedPlaylistPersistentIds);

  MLE_Log_Info(@"  PlaylistCustomSortColumns:       '%@'", _playlistCustomSortColumnDict);
  MLE_Log_Info(@"  PlaylistCustomSortOrders:        '%@'", _playlistCustomSortOrderDict);
}


#pragma mark - Mutators

+ (void)initSharedConfig:(ExportConfiguration*)sharedConfig {

  NSAssert((_sharedConfig == nil), @"ExportConfiguration sharedConfig has already been initialized!");

  _sharedConfig = sharedConfig;
}

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  MLE_Log_Info(@"ExportConfiguration [setMusicLibraryPath %@]", musicLibraryPath);

  _musicLibraryPath = musicLibraryPath;
}

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl {

  MLE_Log_Info(@"ExportConfiguration [setOutputDirectoryUrl %@]", dirUrl);

  _outputDirectoryUrl = dirUrl;
}

- (void)setOutputDirectoryPath:(nullable NSString*)dirPath {

  MLE_Log_Info(@"ExportConfiguration [setOutputDirectoryPath %@]", dirPath);

  _outputDirectoryPath = dirPath;
}

- (void)setOutputFileName:(NSString*)fileName {

  MLE_Log_Info(@"ExportConfiguration [setOutputFileName %@]", fileName);

  _outputFileName = fileName;
}

- (void)setRemapRootDirectory:(BOOL)flag {

  MLE_Log_Info(@"ExportConfiguration [setRemapRootDirectory %@]", (flag ? @"YES" : @"NO"));

  _remapRootDirectory = flag;
}

- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath {

  MLE_Log_Info(@"ExportConfiguration [setRemapRootDirectoryOriginalPath %@]", originalPath);

  _remapRootDirectoryOriginalPath = originalPath;
}

- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath {

  MLE_Log_Info(@"ExportConfiguration [setRemapRootDirectoryMappedPath %@]", mappedPath);

  _remapRootDirectoryMappedPath = mappedPath;
}

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  MLE_Log_Info(@"ExportConfiguration [setFlattenPlaylistHierarchy %@]", (flag ? @"YES" : @"NO"));

  _flattenPlaylistHierarchy = flag;
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  MLE_Log_Info(@"ExportConfiguration [setIncludeInternalPlaylists %@]", (flag ? @"YES" : @"NO"));

  _includeInternalPlaylists = flag;
}

- (void)setExcludedPlaylistPersistentIds:(NSSet<NSNumber*>*)excludedIds {

  _excludedPlaylistPersistentIds = [excludedIds mutableCopy];
}

- (void)addExcludedPlaylistPersistentId:(NSNumber*)playlistId {

  MLE_Log_Info(@"ExportConfiguration [addExcludedPlaylistPersistentId %@]", playlistId);

  [_excludedPlaylistPersistentIds addObject:playlistId];
}

- (void)removeExcludedPlaylistPersistentId:(NSNumber*)playlistId {

  MLE_Log_Info(@"ExportConfiguration [removeExcludedPlaylistPersistentId %@]", playlistId);

  [_excludedPlaylistPersistentIds removeObject:playlistId];
}

- (void)setExcluded:(BOOL)excluded forPlaylistId:(NSNumber*)playlistId {

  if (excluded) {
    [self addExcludedPlaylistPersistentId:playlistId];
  }
  else {
    [self removeExcludedPlaylistPersistentId:playlistId];
  }
}

- (void)setCustomSortColumnDict:(NSDictionary*)dict {

  _playlistCustomSortColumnDict = dict;
}

- (void)setCustomSortOrderDict:(NSDictionary*)dict {

  _playlistCustomSortOrderDict = dict;
}

- (void)setDefaultSortingForPlaylist:(NSNumber*)playlistId {

  [self setCustomSortColumn:PlaylistSortColumnNull forPlaylist:playlistId];
  [self setCustomSortOrder:PlaylistSortOrderNull forPlaylist:playlistId];
}

- (void)setCustomSortColumn:(PlaylistSortColumnType)sortColumn forPlaylist:(NSNumber*)playlistId {

  NSString* sortColumnTitle = [Utils titleForPlaylistSortColumn:sortColumn];
  NSMutableDictionary* sortColumnDict = [_playlistCustomSortColumnDict mutableCopy];

  if (sortColumnTitle) {
    [sortColumnDict setValue:sortColumnTitle forKey:[playlistId stringValue]];
  }
  else {
    [sortColumnDict removeObjectForKey:[playlistId stringValue]];
  }

  [self setCustomSortColumnDict:sortColumnDict];
}

- (void)setCustomSortOrder:(PlaylistSortOrderType)sortOrder forPlaylist:(NSNumber*)playlistId {

  NSString* sortOrderTitle = [Utils titleForPlaylistSortOrder:sortOrder];
  NSMutableDictionary* sortOrderDict = [_playlistCustomSortOrderDict mutableCopy];

  if (sortOrderTitle) {
    [sortOrderDict setValue:sortOrderTitle forKey:[playlistId stringValue]];
  }
  else {
    [sortOrderDict removeObjectForKey:[playlistId stringValue]];
  }

  [self setCustomSortOrderDict:sortOrderDict];
}

@end
