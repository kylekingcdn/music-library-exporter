//
//  UserDefaultsExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-01.
//

#import "UserDefaultsExportConfiguration.h"

#import "Logger.h"

static UserDefaultsExportConfiguration* _sharedConfig;


@implementation UserDefaultsExportConfiguration {

  NSUserDefaults* _userDefaults;
}


#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

  return self;
}


#pragma mark - Accessors

+ (UserDefaultsExportConfiguration*)sharedConfig {

  NSAssert((_sharedConfig != nil), @"UserDefaultsExportConfiguration sharedConfig has not been initialized!");

  return _sharedConfig;
}

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"",             @"MusicLibraryPath",

//  @"",             @"OutputDirectoryBookmark", /* we want this to be nil if it doesn't exist */
    @"",             @"OutputDirectoryPath",
    @"",             @"OutputFileName",

    @NO,             @"RemapRootDirectory",
    @"",             @"RemapRootDirectoryOriginalPath",
    @"",             @"RemapRootDirectoryMappedPath",

    @NO,             @"FlattenPlaylistHierarchy",
    @YES,            @"IncludeInternalPlaylists",
    @[],             @"ExcludedPlaylistPersistentIds",

    @{},             @"PlaylistCustomSortColumns",
    @{},             @"PlaylistCustomSortOrders",

    nil
  ];
}
- (NSString*)outputDirectoryBookmarkKey {

  if (_outputDirectoryBookmarkKeySuffix == nil || _outputDirectoryBookmarkKeySuffix.length == 0) {
    return @"OutputDirectoryBookmark";
  }
  else {
    return [NSString stringWithFormat:@"OutputDirectoryBookmark%@", _outputDirectoryBookmarkKeySuffix];
  }
}

- (nullable NSData*)fetchOutputDirectoryBookmarkData {

  return [_userDefaults dataForKey: [self outputDirectoryBookmarkKey]];
}


#pragma mark - Mutators

+ (void)initSharedConfig:(UserDefaultsExportConfiguration*)sharedConfig {

  NSAssert((_sharedConfig == nil), @"UserDefaultsExportConfiguration sharedConfig has already been initialized!");

  _sharedConfig = sharedConfig;

  // init shared config for superclass
  [ExportConfiguration initSharedConfig:sharedConfig];
}

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  [super setMusicLibraryPath:musicLibraryPath];

  [_userDefaults setValue:musicLibraryPath forKey:@"MusicLibraryPath"];
}

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl {

  NSString* outputDirPath;
  // update path variable
  if (dirUrl && dirUrl.isFileURL) {
    outputDirPath = dirUrl.path;
  }

  [super setOutputDirectoryUrl:dirUrl];
  [self saveBookmarkForOutputDirectoryUrl:dirUrl];

  // since this is being observed by KVO, call it after the bookmark and member variables for the URL have been updated
  [self setOutputDirectoryPath:outputDirPath];
}

- (void)setOutputDirectoryPath:(NSString*)dirPath {

  [super setOutputDirectoryPath:dirPath];

  [_userDefaults setValue:dirPath forKey:@"OutputDirectoryPath"];
}

- (void)setOutputFileName:(NSString*)fileName {

  [super setOutputFileName:fileName];

  [_userDefaults setValue:fileName forKey:@"OutputFileName"];
}

- (void)setRemapRootDirectory:(BOOL)flag {

  [super setRemapRootDirectory:flag];

  [_userDefaults setBool:flag forKey:@"RemapRootDirectory"];
}

- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath {

  [super setRemapRootDirectoryOriginalPath:originalPath];

  [_userDefaults setValue:originalPath forKey:@"RemapRootDirectoryOriginalPath"];
}

- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath {

  [super setRemapRootDirectoryMappedPath:mappedPath];

  [_userDefaults setValue:mappedPath forKey:@"RemapRootDirectoryMappedPath"];
}

- (void)setFlattenPlaylistHierarchy:(BOOL)flag {

  [super setFlattenPlaylistHierarchy:flag];

  [_userDefaults setBool:flag forKey:@"FlattenPlaylistHierarchy"];
}

- (void)setIncludeInternalPlaylists:(BOOL)flag {

  [super setIncludeInternalPlaylists:flag];

  [_userDefaults setBool:flag forKey:@"IncludeInternalPlaylists"];
}

- (void)setExcludedPlaylistPersistentIds:(NSSet<NSNumber*>*)excludedIds {

  [super setExcludedPlaylistPersistentIds:excludedIds];

  [_userDefaults setObject:[excludedIds allObjects] forKey:@"ExcludedPlaylistPersistentIds"];
}

- (void)addExcludedPlaylistPersistentId:(NSNumber*)playlistId {

  [super addExcludedPlaylistPersistentId:playlistId];
  
  [_userDefaults setObject:[[super excludedPlaylistPersistentIds] allObjects] forKey:@"ExcludedPlaylistPersistentIds"];
}

- (void)removeExcludedPlaylistPersistentId:(NSNumber*)playlistId {

  [super removeExcludedPlaylistPersistentId:playlistId];

  [_userDefaults setObject:[[super excludedPlaylistPersistentIds] allObjects] forKey:@"ExcludedPlaylistPersistentIds"];
}

- (void)setCustomSortColumnDict:(NSDictionary*)dict {

  [super setCustomSortColumnDict:dict];

  [_userDefaults setObject:dict forKey:@"PlaylistCustomSortColumns"];
}

- (void)setCustomSortOrderDict:(NSDictionary*)dict {

  [super setCustomSortOrderDict:dict];

  [_userDefaults setObject:dict forKey:@"PlaylistCustomSortOrders"];
}

- (void)loadPropertiesFromUserDefaults {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [loadPropertiesFromUserDefaults]");

  [self registerDefaultValues];

  [super setMusicLibraryPath:[_userDefaults valueForKey:@"MusicLibraryPath"]];

  [super setOutputDirectoryUrl: [self resolveOutputDirectoryBookmarkAndReturnError:nil]];
  // if the bookmark was stale, the above call to resolve would have already updated this value
  [super setOutputDirectoryPath:[_userDefaults valueForKey:@"OutputDirectoryPath"]];
  [super setOutputFileName:[_userDefaults valueForKey:@"OutputFileName"]];

  [super setRemapRootDirectory:[_userDefaults boolForKey:@"RemapRootDirectory"]];
  [super setRemapRootDirectoryOriginalPath:[_userDefaults valueForKey:@"RemapRootDirectoryOriginalPath"]];
  [super setRemapRootDirectoryMappedPath:[_userDefaults valueForKey:@"RemapRootDirectoryMappedPath"]];

  [super setFlattenPlaylistHierarchy:[_userDefaults boolForKey:@"FlattenPlaylistHierarchy"]];
  [super setIncludeInternalPlaylists:[_userDefaults boolForKey:@"IncludeInternalPlaylists"]];
  [super setExcludedPlaylistPersistentIds:[NSSet setWithArray:[_userDefaults arrayForKey:@"ExcludedPlaylistPersistentIds"]]];

  [super setCustomSortColumnDict:[_userDefaults dictionaryForKey:@"PlaylistCustomSortColumns"]];
  [super setCustomSortOrderDict:[_userDefaults dictionaryForKey:@"PlaylistCustomSortOrders"]];
}

- (void)registerDefaultValues {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [registerDefaultValues]");

  [_userDefaults registerDefaults:[self defaultValues]];
}

- (nullable NSURL*)resolveOutputDirectoryBookmarkAndReturnError:(NSError**)error {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [resolveOutputDirectoryBookmarkAndReturnError]");

  // fetch output directory bookmark data
  NSData* outputDirBookmarkData = [self fetchOutputDirectoryBookmarkData];

  // no bookmark has been saved yet
  if (outputDirBookmarkData == nil) {
    MLE_Log_Info(@"UserDefaultsExportConfiguration [resolveOutputDirectoryBookmarkAndReturnError] bookmark is nil");
    return nil;
  }

  // resolve output directory URL for bookmark data
  BOOL outputDirBookmarkIsStale;
  NSURL* outputDirBookmarkUrl = [NSURL URLByResolvingBookmarkData:outputDirBookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&outputDirBookmarkIsStale error:error];

  // error resolving bookmark data
  if (outputDirBookmarkUrl == nil) {
    if (error) {
      MLE_Log_Info(@"UserDefaultsExportConfiguration [resolveOutputDirectoryBookmarkAndReturnError] error resolving output dir bookmark: %@", [*error localizedDescription]);
    }
    [self setOutputDirectoryUrl:nil];
    return nil;
  }

  // bookmark data is stale, update saved bookmark + output path variable
  if (outputDirBookmarkIsStale) {

    MLE_Log_Info(@"UserDefaultsExportConfiguration [resolveOutputDirectoryBookmarkAndReturnError] bookmark is stale, saving new bookmark");

    [outputDirBookmarkUrl startAccessingSecurityScopedResource];
    // we call this instead of saveBookmark since it handles updating internal member variables as well as the path variable
    [self setOutputDirectoryUrl:outputDirBookmarkUrl];
    [outputDirBookmarkUrl stopAccessingSecurityScopedResource];
  }

  MLE_Log_Info(@"UserDefaultsExportConfiguration [resolveOutputDirectoryBookmarkAndReturnError] bookmarked output directory: %@", outputDirBookmarkUrl.path);

  return outputDirBookmarkUrl;
}

- (BOOL)saveBookmarkForOutputDirectoryUrl:(nullable NSURL*)outputDirUrl {

  MLE_Log_Info(@"UserDefaultsExportConfiguration [saveBookmarkForOutputDirectoryUrl: %@]", outputDirUrl);

  if (outputDirUrl == nil) {
    [_userDefaults removeObjectForKey:[self outputDirectoryBookmarkKey]];
    return YES;
  }

  NSError* outputDirBookmarkError;
  NSData* outputDirBookmarkData = [outputDirUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&outputDirBookmarkError];

  // error generating bookmark
  if (outputDirBookmarkError) {
    MLE_Log_Info(@"UserDefaultsExportConfiguration [saveBookmarkForOutputDirectoryUrl] error generating output directory bookmark data: %@", outputDirBookmarkError.localizedDescription);
    return NO;
  }

  // save bookmark data to user defaults
  else {
    [_userDefaults setValue:outputDirBookmarkData forKey:[self outputDirectoryBookmarkKey]];
    return YES;
  }
}

@end
