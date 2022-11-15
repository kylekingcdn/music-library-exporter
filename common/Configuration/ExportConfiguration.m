//
//  ExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ExportConfiguration.h"

#import "Logger.h"
#import "Utils.h"


@implementation ExportConfiguration {

  NSString* _musicLibraryPath;

  NSString* _generatedPersistentLibraryId;

  NSURL* _outputDirectoryUrl;
  NSString* _outputDirectoryPath;
  NSString* _outputFileName;

  BOOL _remapRootDirectory;
  NSString* _remapRootDirectoryOriginalPath;
  NSString* _remapRootDirectoryMappedPath;
  BOOL _remapRootDirectoryLocalhostPrefix;

  BOOL _flattenPlaylistHierarchy;
  BOOL _includeInternalPlaylists;
  NSMutableSet<NSString*>* _excludedPlaylistPersistentIds;

  NSDictionary* _playlistCustomSortColumnDict;
  NSDictionary* _playlistCustomSortOrderDict;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _remapRootDirectory = NO;
    _remapRootDirectoryLocalhostPrefix = NO;

    _flattenPlaylistHierarchy = NO;
    _includeInternalPlaylists = YES;
    _excludedPlaylistPersistentIds = [NSMutableSet set];

    _playlistCustomSortColumnDict = [NSDictionary dictionary];
    _playlistCustomSortOrderDict = [NSDictionary dictionary];

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (NSString*)musicLibraryPath {

  return _musicLibraryPath;
}

- (NSString*)generatedPersistentLibraryId {

  return _generatedPersistentLibraryId;
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

- (BOOL)remapRootDirectoryLocalhostPrefix {

  return _remapRootDirectoryLocalhostPrefix;
}

- (BOOL)flattenPlaylistHierarchy {

    return _flattenPlaylistHierarchy;
}

- (BOOL)includeInternalPlaylists {

    return _includeInternalPlaylists;
}

- (NSSet<NSString*>*)excludedPlaylistPersistentIds {

    return _excludedPlaylistPersistentIds;
}

- (BOOL)isPlaylistIdExcluded:(NSString*)playlistId {

  return [_excludedPlaylistPersistentIds containsObject:playlistId];
}

- (NSDictionary*)playlistCustomSortColumnDict {

  return _playlistCustomSortColumnDict;
}

- (NSDictionary*)playlistCustomSortOrderDict {

  return _playlistCustomSortOrderDict;
}

- (PlaylistSortColumnType)playlistCustomSortColumn:(NSString*)playlistId {

  NSString* sortColumnTitle = [_playlistCustomSortColumnDict valueForKey:playlistId];
  PlaylistSortColumnType sortColumn = [Utils playlistSortColumnForTitle:sortColumnTitle];

  return sortColumn;
}

- (PlaylistSortOrderType)playlistCustomSortOrder:(NSString*)playlistId {

  NSString* sortOrderTitle = [_playlistCustomSortOrderDict valueForKey:playlistId];
  PlaylistSortOrderType sortOrder = [Utils playlistSortOrderForTitle:sortOrderTitle];

  return sortOrder;
}

- (NSString*)generatePersistentLibraryId {

  NSArray<NSString*>* uuidParts = [[NSUUID UUID].UUIDString componentsSeparatedByString:@"-"];
  NSString* newLibraryId = [NSString stringWithFormat:@"%@%@", [uuidParts objectAtIndex:uuidParts.count-2], [uuidParts lastObject]];

  return newLibraryId;
}

- (void)dumpProperties {

  MLE_Log_Info(@"ExportConfiguration [dumpProperties]");

  MLE_Log_Info(@"  MusicLibraryPath:                  '%@'", _musicLibraryPath);

  MLE_Log_Info(@"  GeneratedPersistentLibraryId:      '%@'", _generatedPersistentLibraryId);

  MLE_Log_Info(@"  OutputDirectoryUrl:                '%@'", _outputDirectoryUrl);
  MLE_Log_Info(@"  OutputDirectoryPath:               '%@'", _outputDirectoryPath);
  MLE_Log_Info(@"  OutputFileName:                    '%@'", _outputFileName);

  MLE_Log_Info(@"  RemapRootDirectory:                '%@'", (_remapRootDirectory ? @"YES" : @"NO"));
  MLE_Log_Info(@"  RemapRootDirectoryOriginalPath:    '%@'", _remapRootDirectoryOriginalPath);
  MLE_Log_Info(@"  RemapRootDirectoryMappedPath:      '%@'", _remapRootDirectoryMappedPath);
  MLE_Log_Info(@"  RemapRootDirectoryLocalhostPrefix: '%@'", (_remapRootDirectoryLocalhostPrefix ? @"YES" : @"NO"));

  MLE_Log_Info(@"  FlattenPlaylistHierarchy:          '%@'", (_flattenPlaylistHierarchy ? @"YES" : @"NO"));
  MLE_Log_Info(@"  IncludeInternalPlaylists:          '%@'", (_includeInternalPlaylists ? @"YES" : @"NO"));
  MLE_Log_Info(@"  ExcludedPlaylistPersistentIds:     '%@'", _excludedPlaylistPersistentIds);

  MLE_Log_Info(@"  PlaylistCustomSortColumns:         '%@'", _playlistCustomSortColumnDict);
  MLE_Log_Info(@"  PlaylistCustomSortOrders:          '%@'", _playlistCustomSortOrderDict);
}


#pragma mark - Mutators

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  MLE_Log_Info(@"ExportConfiguration [setMusicLibraryPath %@]", musicLibraryPath);

  _musicLibraryPath = musicLibraryPath;
}

- (void)setGeneratedPersistentLibraryId:(NSString*)generatedPersistentLibraryId {

  MLE_Log_Info(@"ExportConfiguration [setGeneratedPersistentLibraryId %@]", generatedPersistentLibraryId);

  _generatedPersistentLibraryId = generatedPersistentLibraryId;
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

- (void)setRemapRootDirectoryLocalhostPrefix:(BOOL)flag {

  MLE_Log_Info(@"ExportConfiguration [setRemapRootDirectoryLocalhostPrefix %@]", (flag ? @"YES" : @"NO"));

  _remapRootDirectoryLocalhostPrefix = flag;
}

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  MLE_Log_Info(@"ExportConfiguration [setFlattenPlaylistHierarchy %@]", (flag ? @"YES" : @"NO"));

  _flattenPlaylistHierarchy = flag;
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  MLE_Log_Info(@"ExportConfiguration [setIncludeInternalPlaylists %@]", (flag ? @"YES" : @"NO"));

  _includeInternalPlaylists = flag;
}

- (void)setExcludedPlaylistPersistentIds:(NSSet<NSString*>*)excludedIds {

  _excludedPlaylistPersistentIds = [excludedIds mutableCopy];
}

- (void)addExcludedPlaylistPersistentId:(NSString*)playlistId {

  MLE_Log_Info(@"ExportConfiguration [addExcludedPlaylistPersistentId %@]", playlistId);

  [_excludedPlaylistPersistentIds addObject:playlistId];
}

- (void)removeExcludedPlaylistPersistentId:(NSString*)playlistId {

  MLE_Log_Info(@"ExportConfiguration [removeExcludedPlaylistPersistentId %@]", playlistId);

  [_excludedPlaylistPersistentIds removeObject:playlistId];
}

- (void)setExcluded:(BOOL)excluded forPlaylistId:(NSString*)playlistId {

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

- (void)setDefaultSortingForPlaylist:(NSString*)playlistId {

  [self setCustomSortColumn:PlaylistSortColumnNull forPlaylist:playlistId];
  [self setCustomSortOrder:PlaylistSortOrderNull forPlaylist:playlistId];
}

- (void)setCustomSortColumn:(PlaylistSortColumnType)sortColumn forPlaylist:(NSString*)playlistId {

  NSString* sortColumnTitle = [Utils titleForPlaylistSortColumn:sortColumn];
  NSMutableDictionary* sortColumnDict = [_playlistCustomSortColumnDict mutableCopy];

  if (sortColumnTitle) {
    [sortColumnDict setValue:sortColumnTitle forKey:playlistId];
  }
  else {
    [sortColumnDict removeObjectForKey:playlistId];
  }

  [self setCustomSortColumnDict:sortColumnDict];
}

- (void)setCustomSortOrder:(PlaylistSortOrderType)sortOrder forPlaylist:(NSString*)playlistId {

  NSString* sortOrderTitle = [Utils titleForPlaylistSortOrder:sortOrder];
  NSMutableDictionary* sortOrderDict = [_playlistCustomSortOrderDict mutableCopy];

  if (sortOrderTitle) {
    [sortOrderDict setValue:sortOrderTitle forKey:playlistId];
  }
  else {
    [sortOrderDict removeObjectForKey:playlistId];
  }

  [self setCustomSortOrderDict:sortOrderDict];
}

- (void)loadValuesFromDictionary:(NSDictionary*)dict {

  MLE_Log_Info(@"ExportConfiguration [loadValuesFromDictionary] (dict key count:%lu)", dict.count);

  if ([dict objectForKey:ExportConfigurationKeyMusicLibraryPath]) {
    [self setMusicLibraryPath:[dict valueForKey:ExportConfigurationKeyMusicLibraryPath]];
  }
  
  if ([dict objectForKey:ExportConfigurationKeyGeneratedPersistentLibraryId]) {
    [self setGeneratedPersistentLibraryId:[dict valueForKey:ExportConfigurationKeyGeneratedPersistentLibraryId]];
  }

  if ([dict objectForKey:ExportConfigurationKeyOutputDirectoryPath]) {
    [self setOutputDirectoryPath:[dict valueForKey:ExportConfigurationKeyOutputDirectoryPath]];
  }
  if ([dict objectForKey:ExportConfigurationKeyOutputFileName]) {
    [self setOutputFileName:[dict valueForKey:ExportConfigurationKeyOutputFileName]];
  }

  if ([dict objectForKey:ExportConfigurationKeyRemapRootDirectory]) {
    [self setRemapRootDirectory:[[dict objectForKey:ExportConfigurationKeyRemapRootDirectory] boolValue]];
  }
  if ([dict objectForKey:ExportConfigurationKeyRemapRootDirectoryOriginalPath]) {
    [self setRemapRootDirectoryOriginalPath:[dict valueForKey:ExportConfigurationKeyRemapRootDirectoryOriginalPath]];
  }
  if ([dict objectForKey:ExportConfigurationKeyRemapRootDirectoryMappedPath]) {
    [self setRemapRootDirectoryMappedPath:[dict valueForKey:ExportConfigurationKeyRemapRootDirectoryMappedPath]];
  }
  if ([dict objectForKey:ExportConfigurationKeyRemapRootDirectoryLocalhostPrefix]) {
    [self setRemapRootDirectoryLocalhostPrefix:[[dict objectForKey:ExportConfigurationKeyRemapRootDirectoryLocalhostPrefix] boolValue]];
  }

  if ([dict objectForKey:ExportConfigurationKeyFlattenPlaylistHierarchy]) {
    [self setFlattenPlaylistHierarchy:[[dict objectForKey:ExportConfigurationKeyFlattenPlaylistHierarchy] boolValue]];
  }
  if ([dict objectForKey:ExportConfigurationKeyIncludeInternalPlaylists]) {
    [self setIncludeInternalPlaylists:[[dict objectForKey:ExportConfigurationKeyIncludeInternalPlaylists] boolValue]];
  }
  if ([dict objectForKey:ExportConfigurationKeyExcludedPlaylistPersistentIds]) {
    [self setExcludedPlaylistPersistentIds:[NSSet setWithArray:[dict valueForKey:ExportConfigurationKeyExcludedPlaylistPersistentIds]]];
  }

  if ([dict objectForKey:ExportConfigurationKeyPlaylistCustomSortColumns]) {
    [self setCustomSortColumnDict:[dict valueForKey:ExportConfigurationKeyPlaylistCustomSortColumns]];
  }
  if ([dict objectForKey:ExportConfigurationKeyPlaylistCustomSortOrders]) {
    [self setCustomSortOrderDict:[dict valueForKey:ExportConfigurationKeyPlaylistCustomSortOrders]];
  }
}

@end

NSString* const ExportConfigurationKeyMusicLibraryPath = @"MusicLibraryPath";
NSString* const ExportConfigurationKeyGeneratedPersistentLibraryId = @"GeneratedPersistentLibraryId";
NSString* const ExportConfigurationKeyOutputDirectoryPath = @"OutputDirectoryPath";
NSString* const ExportConfigurationKeyOutputDirectoryBookmark = @"OutputDirectoryBookmark";
NSString* const ExportConfigurationKeyOutputFileName = @"OutputFileName";
NSString* const ExportConfigurationKeyRemapRootDirectory = @"RemapRootDirectory";
NSString* const ExportConfigurationKeyRemapRootDirectoryOriginalPath = @"RemapRootDirectoryOriginalPath";
NSString* const ExportConfigurationKeyRemapRootDirectoryMappedPath = @"RemapRootDirectoryMappedPath";
NSString* const ExportConfigurationKeyRemapRootDirectoryLocalhostPrefix = @"RemapRootDirectoryLocalhostPrefix";
NSString* const ExportConfigurationKeyFlattenPlaylistHierarchy = @"FlattenPlaylistHierarchy";
NSString* const ExportConfigurationKeyIncludeInternalPlaylists = @"IncludeInternalPlaylists";
NSString* const ExportConfigurationKeyExcludedPlaylistPersistentIds = @"ExcludedPlaylistPersistentIds";
NSString* const ExportConfigurationKeyPlaylistCustomSortColumns = @"PlaylistCustomSortColumns";
NSString* const ExportConfigurationKeyPlaylistCustomSortOrders = @"PlaylistCustomSortOrders";
