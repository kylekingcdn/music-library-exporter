//
//  ExportConfiguration.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Foundation/Foundation.h>

#include "Defines.h"


NS_ASSUME_NONNULL_BEGIN

@interface ExportConfiguration : NSObject


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (NSString*)musicLibraryPath;

- (NSString*)generatedPersistentLibraryId;

- (nullable NSURL*)outputDirectoryUrl;
- (NSString*)outputDirectoryPath;
- (NSString*)outputDirectoryUrlPath;
- (BOOL)isOutputDirectoryValid;

- (NSString*)outputFileName;
- (BOOL)isOutputFileNameValid;

- (nullable NSURL*)outputFileUrl;
- (NSString*)outputFilePath;
- (BOOL)isOutputFilePathValid;

- (BOOL)remapRootDirectory;
- (NSString*)remapRootDirectoryOriginalPath;
- (NSString*)remapRootDirectoryMappedPath;
- (BOOL)remapRootDirectoryLocalhostPrefix;

- (BOOL)flattenPlaylistHierarchy;
- (BOOL)includeInternalPlaylists;
- (NSSet<NSString*>*)excludedPlaylistPersistentIds;
- (BOOL)isPlaylistIdExcluded:(NSString*)playlistId;

- (NSDictionary*)playlistCustomSortColumnDict;
- (NSDictionary*)playlistCustomSortOrderDict;

- (PlaylistSortColumnType)playlistCustomSortColumn:(NSString*)playlistId;
- (PlaylistSortOrderType)playlistCustomSortOrder:(NSString*)playlistId;

- (NSString*)generatePersistentLibraryId;

- (void)dumpProperties;


#pragma mark - Mutators

- (void)setGeneratedPersistentLibraryId:(NSString*)generatedPersistentLibraryId;

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath;

- (void)setOutputDirectoryPath:(nullable NSString*)dirPath;
- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl;
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
- (void)setExcluded:(BOOL)excluded forPlaylistId:(NSString*)playlistId;

- (void)setCustomSortColumnDict:(NSDictionary*)dict;
- (void)setCustomSortOrderDict:(NSDictionary*)dict;

- (void)setDefaultSortingForPlaylist:(NSString*)playlistId;
- (void)setCustomSortColumn:(PlaylistSortColumnType)sortColumn forPlaylist:(NSString*)playlistId;
- (void)setCustomSortOrder:(PlaylistSortOrderType)sortOrder forPlaylist:(NSString*)playlistId;

- (void)loadValuesFromDictionary:(NSDictionary*)dict;

@end

NS_ASSUME_NONNULL_END
