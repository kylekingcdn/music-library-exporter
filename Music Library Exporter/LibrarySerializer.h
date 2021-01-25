//
//  serializer.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import "OrderedDictionary.h"

@class ITLibrary;
@class ITLibMediaEntity;
@class ITLibMediaItem;
@class ITLibPlaylist;
@class ITLibArtist;

NS_ASSUME_NONNULL_BEGIN

@interface LibrarySerializer : NSObject {

  NSUInteger currentEntityId;
  MutableOrderedDictionary* entityIdsDicts;

  // returns constant value based on initial parameters - generated during run-time for optimized performance
  BOOL hasPlaylistIdWhitelist;
  BOOL shouldRemapTrackLocations;
}

@property (readonly) MutableOrderedDictionary* libraryDict;
@property NSString* filePath;

// dict value modifiers
@property BOOL remapRootDirectory;
@property NSString* originalRootDirectory;
@property NSString* mappedRootDirectory;
@property BOOL flattenPlaylistHierarchy;

// key filters
@property BOOL includeInternalPlaylists;
@property NSArray<NSString*>* includedPlaylistPersistentIds;
@property BOOL includeFoldersWhenFlattened;

+ (NSString*) getHexadecimalPersistentIdForEntity:(ITLibMediaEntity*)entity;
+ (NSString*) getHexadecimalPersistentId:(NSNumber*)decimalPersistentId;

+ (void) dumpPropertiesForEntity: (ITLibMediaEntity*) entity;
+ (void) dumpPropertiesForEntity: (ITLibMediaEntity*) entity withoutProperties: (NSSet<NSString *> * _Nullable) excludedProperties;

+ (void) dumpLibraryPlaylists: (ITLibrary*) library;
+ (void) dumpLibraryTracks: (ITLibrary*) library;

- (NSString*) remapRootMusicDirForFilePath:(NSString*)filePath;

- (void) serializeLibrary: (ITLibrary*) library;

- (NSMutableArray<OrderedDictionary*>*) serializePlaylists: (NSArray<ITLibPlaylist*>*) playlists;
- (OrderedDictionary*) serializePlaylist: (ITLibPlaylist*) playlistItem withId: (NSUInteger) playlistId;
- (NSMutableArray<OrderedDictionary*>*) serializePlaylistItems: (NSArray<ITLibMediaItem*>*) trackItems;

- (OrderedDictionary*) serializeTracks: (NSArray<ITLibMediaItem*>*) tracks;
- (OrderedDictionary*) serializeTrack: (ITLibMediaItem*) trackItem withId: (NSUInteger) trackId;

- (void) writeDictionary;

@end

NS_ASSUME_NONNULL_END
