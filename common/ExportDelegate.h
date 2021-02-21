//
//  ExportDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import <Foundation/Foundation.h>

#import "Defines.h"

@class ITLibrary;
@class ITLibMediaItem;
@class ITLibPlaylist;
@class OrderedDictionary;


NS_ASSUME_NONNULL_BEGIN

@interface ExportDelegate : NSObject


#pragma mark - Properties

@property (readonly) ExportState state;

@property (copy) void (^trackProgressCallback)(NSUInteger,NSUInteger);
@property (copy) void (^playlistProgressCallback)(NSUInteger,NSUInteger);
@property (copy) void (^stateCallback)(NSInteger);

@property (readonly) NSArray<ITLibMediaItem*>* includedTracks;
@property (readonly) NSArray<ITLibPlaylist*>* includedPlaylists;


#pragma mark - Initializers

- (instancetype)initWithLibrary:(ITLibrary*)library;


#pragma mark - Mutators

- (BOOL)prepareForExportAndReturnError:(NSError**)error;
- (BOOL)exportLibraryAndReturnError:(NSError**)error;

- (BOOL)writeDictionary:(OrderedDictionary*)libraryDict error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
