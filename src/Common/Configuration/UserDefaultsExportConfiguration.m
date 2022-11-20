//
//  UserDefaultsExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-01.
//

#import "UserDefaultsExportConfiguration.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "Logger.h"


@implementation UserDefaultsExportConfiguration {

  NSUserDefaults* _userDefaults;

  NSString* _outputDirectoryBookmarkKey;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

    _outputDirectoryBookmarkKey = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithOutputDirectoryBookmarkKey:(NSString*)outputDirectoryBookmarkKey {

  if (self = [self init]) {

    _outputDirectoryBookmarkKey = outputDirectoryBookmarkKey;

    // observe changes of output directory bookmark to allow for automatic updating of OutputDirectoryPath
    [_userDefaults addObserver:self forKeyPath:_outputDirectoryBookmarkKey options:NSKeyValueObservingOptionNew context:NULL];

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"",             ExportConfigurationKeyMusicLibraryPath,

//  nil,             ExportConfigurationKeyGeneratedPersistentLibraryId,

    @"",             ExportConfigurationKeyOutputDirectoryPath,
    @"",             ExportConfigurationKeyOutputFileName,

    @NO,             ExportConfigurationKeyRemapRootDirectory,
    @"",             ExportConfigurationKeyRemapRootDirectoryOriginalPath,
    @"",             ExportConfigurationKeyRemapRootDirectoryMappedPath,
    @NO,             ExportConfigurationKeyRemapRootDirectoryLocalhostPrefix,

    @NO,             ExportConfigurationKeyFlattenPlaylistHierarchy,
    @YES,            ExportConfigurationKeyIncludeInternalPlaylists,
    @[],             ExportConfigurationKeyExcludedPlaylistPersistentIds,

    @{},             ExportConfigurationKeyPlaylistCustomSortProperties,
    @{},             ExportConfigurationKeyPlaylistCustomSortOrders,

    NO,              UserDefaultsExportConfigurationSortColumnsMigrated,

    nil
  ];
}

#pragma mark - Mutators

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  [super setMusicLibraryPath:musicLibraryPath];

  [_userDefaults setValue:musicLibraryPath forKey:ExportConfigurationKeyMusicLibraryPath];
}

- (void)setGeneratedPersistentLibraryId:(NSString*)generatedPersistentLibraryId {

  [super setGeneratedPersistentLibraryId:generatedPersistentLibraryId];

  [_userDefaults setValue:generatedPersistentLibraryId forKey:ExportConfigurationKeyGeneratedPersistentLibraryId];
}

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl {

  [super setOutputDirectoryUrl:dirUrl];

  // The NSUserDefaults setValue call is skipped here as this is done by the security scoped bookmark handler
}

- (void)setOutputDirectoryPath:(nullable NSString*)dirPath {

  [super setOutputDirectoryPath:dirPath];

  [_userDefaults setValue:dirPath forKey:ExportConfigurationKeyOutputDirectoryPath];
}

- (void)setOutputFileName:(NSString*)fileName {

  [super setOutputFileName:fileName];

  [_userDefaults setValue:fileName forKey:ExportConfigurationKeyOutputFileName];
}

- (void)setRemapRootDirectory:(BOOL)flag {

  [super setRemapRootDirectory:flag];

  [_userDefaults setBool:flag forKey:ExportConfigurationKeyRemapRootDirectory];
}

- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath {

  [super setRemapRootDirectoryOriginalPath:originalPath];

  [_userDefaults setValue:originalPath forKey:ExportConfigurationKeyRemapRootDirectoryOriginalPath];
}

- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath {

  [super setRemapRootDirectoryMappedPath:mappedPath];

  [_userDefaults setValue:mappedPath forKey:ExportConfigurationKeyRemapRootDirectoryMappedPath];
}

- (void)setRemapRootDirectoryLocalhostPrefix:(BOOL)flag {

  [super setRemapRootDirectoryLocalhostPrefix:flag];

  [_userDefaults setBool:flag forKey:ExportConfigurationKeyRemapRootDirectoryLocalhostPrefix];
}

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  [super setFlattenPlaylistHierarchy:flag];

  [_userDefaults setBool:flag forKey:ExportConfigurationKeyFlattenPlaylistHierarchy];
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  [super setIncludeInternalPlaylists:flag];

  [_userDefaults setBool:flag forKey:ExportConfigurationKeyIncludeInternalPlaylists];
}

- (void)setExcludedPlaylistPersistentIds:(NSSet<NSString*>*)excludedIds {

  [super setExcludedPlaylistPersistentIds:excludedIds];

  [_userDefaults setObject:[excludedIds allObjects] forKey:ExportConfigurationKeyExcludedPlaylistPersistentIds];
}

- (void)addExcludedPlaylistPersistentId:(NSString*)playlistId {

  [super addExcludedPlaylistPersistentId:playlistId];
  
  [_userDefaults setObject:[[super excludedPlaylistPersistentIds] allObjects] forKey:ExportConfigurationKeyExcludedPlaylistPersistentIds];
}

- (void)removeExcludedPlaylistPersistentId:(NSString*)playlistId {

  [super removeExcludedPlaylistPersistentId:playlistId];

  [_userDefaults setObject:[[super excludedPlaylistPersistentIds] allObjects] forKey:ExportConfigurationKeyExcludedPlaylistPersistentIds];
}

- (void)setCustomSortPropertyDict:(NSDictionary*)dict {

  [super setCustomSortPropertyDict:dict];

  [_userDefaults setObject:dict forKey:ExportConfigurationKeyPlaylistCustomSortProperties];
}

- (void)setCustomSortOrderDict:(NSDictionary*)dict {

  [super setCustomSortOrderDict:dict];

  [_userDefaults setObject:dict forKey:ExportConfigurationKeyPlaylistCustomSortOrders];
}

- (void)loadPropertiesFromUserDefaults {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [loadPropertiesFromUserDefaults]");

  [_userDefaults registerDefaults:[self defaultValues]];

  [super loadValuesFromDictionary:[_userDefaults dictionaryRepresentation]];

  if ([self generatedPersistentLibraryId] == nil) {
    [self setGeneratedPersistentLibraryId:[ExportConfiguration generatePersistentLibraryId]];
  }

  // migrate old sort column values
  BOOL sortColumnsMigrated = [[_userDefaults objectForKey:UserDefaultsExportConfigurationSortColumnsMigrated] boolValue];

  if (!sortColumnsMigrated) {
    [self migrateSortColumnsToSortProperties];
  }
}

- (void)migrateSortColumnsToSortProperties {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [migrateSortColumnsToSortProperties] Migrating sort columns...");

  NSMutableDictionary* sortProperties = [[self playlistCustomSortPropertyDict] mutableCopy];
  for (NSString* playlistID in [sortProperties allKeys]) {

    NSString* sortProperty = [sortProperties valueForKey:playlistID];
    if ([sortProperty isEqualToString:@"Title"]) {
      [sortProperties setValue:ITLibMediaItemPropertyTitle forKey:playlistID];
    }
    else if ([sortProperty isEqualToString:@"Artist"]) {
      [sortProperties setValue:ITLibMediaItemPropertyArtistName forKey:playlistID];
    }
    else if ([sortProperty isEqualToString:@"Album Artist"]) {
      [sortProperties setValue:ITLibMediaItemPropertyAlbumArtist forKey:playlistID];
    }
    else if ([sortProperty isEqualToString:@"Date Added"]) {
      [sortProperties setValue:ITLibMediaItemPropertyAddedDate forKey:playlistID];
    }
  }

  [self setCustomSortPropertyDict:sortProperties];

  [_userDefaults setBool:YES forKey:UserDefaultsExportConfigurationSortColumnsMigrated];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:_outputDirectoryBookmarkKey]) {

    NSData* bookmarkData = [_userDefaults dataForKey:aKeyPath];
    if (bookmarkData == nil) {
      [self setOutputDirectoryUrl:nil];
      return;
    }
    // update output directory url
    else {
      NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:nil error:nil];
      [self setOutputDirectoryUrl:bookmarkURL];
    }
  }
}

@end

NSString* const UserDefaultsExportConfigurationSortColumnsMigrated = @"PlaylistCustomSortColumnsMigrated";
