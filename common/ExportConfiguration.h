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

  NSString* _outputDirectoryPath;
  NSString* _outputFileName;

  BOOL _remapRootDirectory;
  NSString* _remapRootDirectoryOriginalPath;
  NSString* _remapRootDirectoryMappedPath;

  BOOL _flattenPlaylistHierarchy;
  BOOL _includeInternalPlaylists;
  NSArray<NSString*>* _excludedPlaylistPersistentIds;

  BOOL _scheduleEnabled;
  NSInteger _scheduleInterval;

  NSDate* _lastExport;
}


#pragma mark - Constructors -

- (instancetype)init;

- (instancetype)initWithUserDefaults;


#pragma mark - Accessors -

- (NSString*)musicLibraryPath;

- (NSString*)ouputDirectoryPath;
- (NSString*)ouputFileName;
- (nullable NSString*)outputFilePath;

- (BOOL)remapRootDirectory;
- (NSString*)remapRootDirectoryOriginalPath;
- (NSString*)remapRootDirectoryMappedPath;

- (BOOL)flattenPlaylistHierarchy;
- (BOOL)includeInternalPlaylists;
- (NSArray<NSString*>*)excludedPlaylistPersistentIds;

- (BOOL)scheduleEnabled;
- (NSInteger)scheduleInterval;

- (NSDate*)lastExport;

- (void)dumpConfiguration;


#pragma mark - Mutators -

- (void)setMusicLibraryPath:(NSString*)musicLibraryPath;

- (void)setOutputDirectoryPath:(NSString*)path;
- (void)setOutputFileName:(NSString*)fileName;

- (void)setRemapRootDirectory:(BOOL)flag;
- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath;
- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath;

- (void)setFlattenPlaylistHierarchy:(BOOL)flag;
- (void)setIncludeInternalPlaylists:(BOOL)flag;
- (void)setExcludedPlaylistPersistentIds:(NSArray<NSString*>*)excludedIds;

- (void)setScheduleEnabled:(BOOL)flag;
- (void)setScheduleInterval:(NSInteger)interval;

- (void)setLastExport:(NSDate*)lastExport;

- (void)setValuesFromUserDefaults;

@end

NS_ASSUME_NONNULL_END
