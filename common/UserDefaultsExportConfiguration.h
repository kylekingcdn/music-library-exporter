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


#pragma mark - Initializers -

- (instancetype)initWithUserDefaultsSuiteName:(NSString*)suiteName;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;

- (NSString*)outputDirectoryBookmarkKey;
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
- (void)setExcludedPlaylistPersistentIds:(NSArray<NSNumber*>*)excludedIds;

- (void)loadPropertiesFromUserDefaults;
- (void)registerDefaultValues;

- (nullable NSURL*)resolveAndAutoRenewOutputDirectoryUrl;
- (BOOL)saveBookmarkForOutputDirectoryUrl:(NSURL*)outputDirUrl;

@end

NS_ASSUME_NONNULL_END
