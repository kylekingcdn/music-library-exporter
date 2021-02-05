//
//  ExportDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import <Foundation/Foundation.h>

#import "Defines.h"

@class ITLibMediaItem;
@class ITLibPlaylist;
@class OrderedDictionary;
@class UserDefaultsExportConfiguration;


NS_ASSUME_NONNULL_BEGIN

@interface ExportDelegate : NSObject


#pragma mark - Properties -

@property (readonly) ExportState state;

@property UserDefaultsExportConfiguration* configuration;

@property (copy) void (^progressCallback)(NSUInteger);
@property (copy) void (^stateCallback)(NSInteger);


#pragma mark - Initializers -

- (instancetype)init;

- (instancetype)initWithConfiguration:(UserDefaultsExportConfiguration*)config;


#pragma mark - Accessors -

- (nullable NSDate*)lastExportedAt;

- (nullable NSArray<ITLibMediaItem*>*)includedTracks;
- (nullable NSArray<ITLibPlaylist*>*)includedPlaylists;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setLastExportedAt:(nullable NSDate*)timestamp;

- (BOOL)prepareForExport;
- (void)exportLibrary;

- (BOOL)writeDictionary:(OrderedDictionary*)libraryDict;

@end

NS_ASSUME_NONNULL_END
