//
//  UserDefaultsExportConfiguration.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-01.
//

#import <Foundation/Foundation.h>

#import "ExportConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaultsExportConfiguration : ExportConfiguration


#pragma mark - Constructors -

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults;
- (instancetype)initWithUserDefaultsSuiteName:(NSString*)suiteName;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath;

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl;
- (void)setOutputFileName:(NSString*)fileName;

- (void)setRemapRootDirectory:(BOOL)flag;
- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath;
- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath;

- (void)setFlattenPlaylistHierarchy:(BOOL)flag;
- (void)setIncludeInternalPlaylists:(BOOL)flag;
- (void)setExcludedPlaylistPersistentIds:(NSArray<NSString*>*)excludedIds;

- (void)loadPropertiesFromUserDefaults;
- (void)registerDefaultValues;

@end

NS_ASSUME_NONNULL_END
