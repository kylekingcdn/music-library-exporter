//
//  UserDefaultsExportConfiguration.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-01.
//

#import "UserDefaultsExportConfiguration.h"


@implementation UserDefaultsExportConfiguration {

  NSUserDefaults* _userDefaults;
}


#pragma mark - Initializers -

- (instancetype)initWithUserDefaultsSuiteName:(NSString*)suiteName {

  self = [super init];

  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

  return self;
}


#pragma mark - Accessors -

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"",             @"MusicLibraryPath",

//  @"",             @"OutputDirectoryBookmark", /* we want this to be nil if it doesn't exist */
    @"Library.xml",  @"OutputFileName",

    @NO,             @"RemapRootDirectory",
    @"",             @"RemapRootDirectoryOriginalPath",
    @"",             @"RemapRootDirectoryMappedPath",

    @NO,             @"FlattenPlaylistHierarchy",
    @YES,            @"IncludeInternalPlaylists",
    @[],             @"ExcludedPlaylistPersistentIds",

    nil
  ];
}

- (nullable NSData*)fetchOutputDirectoryBookmarkData {

  return [_userDefaults dataForKey:@"OutputDirectoryBookmark"];
}


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  [super setMusicLibraryPath:musicLibraryPath];

  [_userDefaults setValue:musicLibraryPath forKey:@"MusicLibraryPath"];
}

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl {

  [super setOutputDirectoryUrl:dirUrl];

  [self saveBookmarkForOutputDirectoryUrl:dirUrl];
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

- (void)setExcludedPlaylistPersistentIds:(NSArray<NSNumber*>*)excludedIds {

  [super setExcludedPlaylistPersistentIds:excludedIds];

  [_userDefaults setValue:excludedIds forKey:@"ExcludedPlaylistPersistentIds"];
}

- (void)loadPropertiesFromUserDefaults {

  NSLog(@"UserDefaultsExportConfiguration [loadPropertiesFromUserDefaults]");

  [self registerDefaultValues];

  [super setMusicLibraryPath:[_userDefaults valueForKey:@"MusicLibraryPath"]];

  [super setOutputDirectoryUrl:[self resolveAndAutoRenewOutputDirectoryUrl]];
  [super setOutputFileName:[_userDefaults valueForKey:@"OutputFileName"]];

  [super setRemapRootDirectory:[_userDefaults boolForKey:@"RemapRootDirectory"]];
  [super setRemapRootDirectoryOriginalPath:[_userDefaults valueForKey:@"RemapRootDirectoryOriginalPath"]];
  [super setRemapRootDirectoryMappedPath:[_userDefaults valueForKey:@"RemapRootDirectoryMappedPath"]];

  [super setFlattenPlaylistHierarchy:[_userDefaults boolForKey:@"FlattenPlaylistHierarchy"]];
  [super setIncludeInternalPlaylists:[_userDefaults boolForKey:@"IncludeInternalPlaylists"]];
  [super setExcludedPlaylistPersistentIds:[_userDefaults arrayForKey:@"ExcludedPlaylistPersistentIds"]];
}

- (void)registerDefaultValues {

  NSLog(@"UserDefaultsExportConfiguration [registerDefaultValues]");

  [_userDefaults registerDefaults:[self defaultValues]];
}

- (nullable NSURL*)resolveAndAutoRenewOutputDirectoryUrl {

  // fetch output directory bookmark data
  NSData* outputDirBookmarkData = [self fetchOutputDirectoryBookmarkData];

  // no bookmark has been saved yet
  if (!outputDirBookmarkData) {
    return nil;
  }

  // resolve output directory URL for bookmark data
  BOOL outputDirBookmarkIsStale;
  NSError* outputDirBookmarkResolutionError;
  NSURL* outputDirBookmarkUrl = [NSURL URLByResolvingBookmarkData:outputDirBookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&outputDirBookmarkIsStale error:&outputDirBookmarkResolutionError];

  // error resolving bookmark data
  if (outputDirBookmarkResolutionError) {
    NSLog(@"UserDefaultsExportConfiguration [fetchAndAutoRenewOutputDirectoryUrl] error resolving output dir bookmark: %@", outputDirBookmarkResolutionError.localizedDescription);
    return nil;
  }

  NSAssert(outputDirBookmarkUrl != nil, @"NSURL retreived from bookmark is nil");
  NSLog(@"UserDefaultsExportConfiguration [fetchAndAutoRenewOutputDirectoryUrl] bookmarked output directory: %@", outputDirBookmarkUrl.path);

  // bookmark data is stale, attempt to renew
  if (outputDirBookmarkIsStale) {

    NSError* outputDirBookmarkRenewError;
    NSLog(@"UserDefaultsExportConfiguration [fetchAndAutoRenewOutputDirectoryUrl] bookmark is stale, attempting renewal");

    [outputDirBookmarkUrl startAccessingSecurityScopedResource];
    outputDirBookmarkData = [outputDirBookmarkUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&outputDirBookmarkRenewError];
    [outputDirBookmarkUrl stopAccessingSecurityScopedResource];

    [self saveBookmarkForOutputDirectoryUrl:outputDirBookmarkUrl];

    if (outputDirBookmarkRenewError) {
      NSLog(@"UserDefaultsExportConfiguration [fetchAndAutoRenewOutputDirectoryUrl] error renewing bookmark: %@", outputDirBookmarkRenewError.localizedDescription);
      return nil;
    }
  }
  else {
    NSLog(@"UserDefaultsExportConfiguration [fetchAndAutoRenewOutputDirectoryUrl] bookmarked output directory is valid");
  }

  return outputDirBookmarkUrl;
}

- (BOOL)saveBookmarkForOutputDirectoryUrl:(NSURL*)outputDirUrl {

  NSLog(@"UserDefaultsExportConfiguration [saveBookmarkForOutputDirectoryUrl: %@]", outputDirUrl);

  NSError* outputDirBookmarkError;
  NSData* outputDirBookmarkData = [outputDirUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&outputDirBookmarkError];

  // error generating bookmark
  if (outputDirBookmarkError) {
    NSLog(@"UserDefaultsExportConfiguration [saveBookmarkForOutputDirectoryUrl] error generating output directory bookmark data: %@", outputDirBookmarkError.localizedDescription);
    return NO;
  }

  // save bookmark data to user defaults
  else {

    [_userDefaults setValue:outputDirBookmarkData forKey:@"OutputDirectoryBookmark"];
    [super setOutputDirectoryUrl:outputDirUrl];

    return YES;
  }
}

@end
