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


#pragma mark - Constructors -

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults {

  self = [super init];

  _userDefaults = userDefaults;

  [self loadPropertiesFromUserDefaults];
  [self dumpConfiguration];

  return self;
}

- (instancetype)initWithUserDefaultsSuiteName:(NSString*)suiteName {

  NSUserDefaults* userDefaultsForSuiteName = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

  return [self initWithUserDefaults:userDefaultsForSuiteName];
}


#pragma mark - Accessors -

- (NSDictionary*)defaultValues {

  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"",             @"MusicLibraryPath",

    @"",             @"OutputDirectoryUrl",
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


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath {

  [super setMusicLibraryPath:musicLibraryPath];

  [_userDefaults setValue:musicLibraryPath forKey:@"MusicLibraryPath"];
}

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl {

  [super setOutputDirectoryUrl:dirUrl];

  [_userDefaults setURL:dirUrl forKey:@"OutputDirectoryUrl"];
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

- (void)setExcludedPlaylistPersistentIds:(NSArray<NSString*>*)excludedIds {

  [super setExcludedPlaylistPersistentIds:excludedIds];

  [_userDefaults setValue:excludedIds forKey:@"ExcludedPlaylistPersistentIds"];
}

- (void)loadPropertiesFromUserDefaults {

  [self registerDefaultValues];

  [super setMusicLibraryPath:[_userDefaults valueForKey:@"MusicLibraryPath"]];

  [super setOutputDirectoryUrl:[_userDefaults URLForKey:@"OutputDirectoryUrl"]];
  [super setOutputFileName:[_userDefaults valueForKey:@"OutputFileName"]];

  [super setRemapRootDirectory:[_userDefaults boolForKey:@"RemapRootDirectory"]];
  [super setRemapRootDirectoryOriginalPath:[_userDefaults valueForKey:@"RemapRootDirectoryOriginalPath"]];
  [super setRemapRootDirectoryMappedPath:[_userDefaults valueForKey:@"RemapRootDirectoryMappedPath"]];

  [super setFlattenPlaylistHierarchy:[_userDefaults boolForKey:@"FlattenPlaylistHierarchy"]];
  [super setIncludeInternalPlaylists:[_userDefaults boolForKey:@"IncludeInternalPlaylists"]];
  [super setExcludedPlaylistPersistentIds:[_userDefaults valueForKey:@"ExcludedPlaylistPersistentIds"]];
}

- (void)registerDefaultValues {

  NSLog(@"[registerDefaultValues]");

  [_userDefaults registerDefaults:[self defaultValues]];
}

@end
