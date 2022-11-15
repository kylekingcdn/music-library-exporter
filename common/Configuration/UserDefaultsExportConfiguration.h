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

@property NSString* outputDirectoryBookmarkKeySuffix;


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (NSDictionary*)defaultValues;

- (NSString*)outputDirectoryBookmarkKey;
- (nullable NSData*)fetchOutputDirectoryBookmarkData;


#pragma mark - Mutators

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath;

- (void)setGeneratedPersistentLibraryId:(NSString*)generatedPersistentLibraryId;

- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl;
- (void)setOutputDirectoryPath:(nullable NSString*)dirPath;
- (void)setOutputFileName:(NSString*)fileName;

- (void)setRemapRootDirectory:(BOOL)flag;
- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath;
- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath;
- (void)setRemapRootDirectoryLocalhostPrefix:(BOOL)flag;

- (void)setFlattenPlaylistHierarchy:(BOOL)flag;
- (void)setIncludeInternalPlaylists:(BOOL)flag;

- (void)setExcludedPlaylistPersistentIds:(NSSet<NSString*>*)excludedIds;
- (void)addExcludedPlaylistPersistentId:(NSString*)playlistId;
- (void)removeExcludedPlaylistPersistentId:(NSString*)playlistId;

- (void)setCustomSortColumnDict:(NSDictionary*)dict;
- (void)setCustomSortOrderDict:(NSDictionary*)dict;

- (void)loadPropertiesFromUserDefaults;
- (void)registerDefaultValues;

- (nullable NSURL*)resolveOutputDirectoryBookmarkAndReturnError:(NSError**)error;
- (BOOL)saveBookmarkForOutputDirectoryUrl:(nullable NSURL*)outputDirUrl;

- (BOOL)validateOutputDirectoryBookmarkAndReturnError:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
