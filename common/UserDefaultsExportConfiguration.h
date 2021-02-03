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


#pragma mark - Initializers -

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults;
- (instancetype)initWithUserDefaultsSuiteName:(NSString*)suiteName;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;

- (nullable NSData*)fetchOutputDirectoryBookmarkData;


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

- (void)setLastExportedAt:(nullable NSDate*)timestamp;

- (void)loadPropertiesFromUserDefaults;
- (void)registerDefaultValues;

- (nullable NSURL*)resolveAndAutoRenewOutputDirectoryUrl;
- (BOOL)saveBookmarkForOutputDirectoryUrl:(NSURL*)outputDirUrl;

@end

NS_ASSUME_NONNULL_END
