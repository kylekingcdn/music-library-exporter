//
//  ExportConfiguration.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExportConfiguration : NSObject {

  NSString* _musicLibraryPath;

  NSURL* _outputDirectoryUrl;
  NSString* _outputFileName;

  BOOL _remapRootDirectory;
  NSString* _remapRootDirectoryOriginalPath;
  NSString* _remapRootDirectoryMappedPath;

  BOOL _flattenPlaylistHierarchy;
  BOOL _includeInternalPlaylists;
  NSArray<NSString*>* _excludedPlaylistPersistentIds;
}


#pragma mark - Constructors -

- (instancetype)init;


#pragma mark - Accessors -

- (NSString*)musicLibraryPath;

- (nullable NSURL*)outputDirectoryUrl;
- (NSString*)outputDirectoryPath;
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
- (NSArray<NSString*>*)excludedPlaylistPersistentIds;

- (void)dumpConfiguration;


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

@end

NS_ASSUME_NONNULL_END
