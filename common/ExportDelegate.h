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

@property (copy) void (^trackProgressCallback)(NSUInteger);
@property (copy) void (^stateCallback)(NSInteger);

@property (readonly) NSArray<ITLibMediaItem*>* includedTracks;
@property (readonly) NSArray<ITLibPlaylist*>* includedPlaylists;


#pragma mark - Initializers -

- (instancetype)init;

- (instancetype)initWithConfiguration:(UserDefaultsExportConfiguration*)config;


#pragma mark - Mutators -

- (BOOL)prepareForExport;
- (void)exportLibrary;

- (BOOL)writeDictionary:(OrderedDictionary*)libraryDict;

@end

NS_ASSUME_NONNULL_END
