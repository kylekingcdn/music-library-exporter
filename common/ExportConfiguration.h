//
//  ExportConfiguration.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface ExportConfiguration : NSObject


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (NSString*)musicLibraryPath;

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

- (BOOL)flattenPlaylistHierarchy;
- (BOOL)includeInternalPlaylists;
- (NSSet<NSNumber*>*)excludedPlaylistPersistentIds;
- (BOOL)isPlaylistIdExcluded:(NSNumber*)playlistId;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath;

- (void)setOutputDirectoryPath:(NSString*)dirPath;
- (void)setOutputDirectoryUrl:(nullable NSURL*)dirUrl;
- (void)setOutputFileName:(NSString*)fileName;

- (void)setRemapRootDirectory:(BOOL)flag;
- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath;
- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath;

- (void)setFlattenPlaylistHierarchy:(BOOL)flag;
- (void)setIncludeInternalPlaylists:(BOOL)flag;

- (void)setExcludedPlaylistPersistentIds:(NSSet<NSNumber*>*)excludedIds;
- (void)addExcludedPlaylistPersistentId:(NSNumber*)playlistId;
- (void)removeExcludedPlaylistPersistentId:(NSNumber*)playlistId;
- (void)setExcluded:(BOOL)excluded forPlaylistId:(NSNumber*)playlistId;

@end

NS_ASSUME_NONNULL_END
