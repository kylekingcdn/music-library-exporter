//
//  serializer.h
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

@class ITLibrary;
@class ITLibMediaEntity;
@class ITLibMediaItem;
@class ITLibPlaylist;
@class ITLibArtist;
@class OrderedDictionary;
@class MutableOrderedDictionary;
@class ExportConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface LibrarySerializer : NSObject {

  NSUInteger currentEntityId;
  NSMutableDictionary* entityIdsDicts;

  // member variables stored at run-time to handle filtering content
  NSSet<NSNumber*>* includedMediaKinds;
  NSSet<NSNumber*>* includedPlaylistKinds;
  BOOL hasPlaylistIdWhitelist;
  BOOL shouldRemapTrackLocations;
}


#pragma mark - Properties -

@property ExportConfiguration* configuration;

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


#pragma mark - Initializers -

- (instancetype)initWithConfiguration:(ExportConfiguration*)exportConfig;


#pragma mark - Utils -

+ (NSString*) getHexadecimalPersistentIdForEntity:(ITLibMediaEntity*)entity;
+ (NSString*) getHexadecimalPersistentId:(NSNumber*)decimalPersistentId;

+ (void) dumpPropertiesForEntity: (ITLibMediaEntity*) entity;
+ (void) dumpPropertiesForEntity: (ITLibMediaEntity*) entity withoutProperties: (NSSet<NSString *> * _Nullable) excludedProperties;

+ (void) dumpLibraryPlaylists: (ITLibrary*) library;
+ (void) dumpLibraryTracks: (ITLibrary*) library;


#pragma mark - Accessors -

- (NSString*) remapRootMusicDirForFilePath:(NSString*)filePath;


#pragma mark - Mutators -

- (void) initSerializeMembers;
- (void) initIncludedMediaKindsDict;
- (void) initIncludedPlaylistKindsDict;

- (void) serializeLibrary: (ITLibrary*) library;

- (NSMutableArray<OrderedDictionary*>*) serializePlaylists: (NSArray<ITLibPlaylist*>*) playlists;
- (OrderedDictionary*) serializePlaylist: (ITLibPlaylist*) playlistItem withId: (NSUInteger) playlistId;
- (NSMutableArray<OrderedDictionary*>*) serializePlaylistItems: (NSArray<ITLibMediaItem*>*) trackItems;

- (OrderedDictionary*) serializeTracks: (NSArray<ITLibMediaItem*>*) tracks;
- (OrderedDictionary*) serializeTrack: (ITLibMediaItem*) trackItem withId: (NSUInteger) trackId;

- (void) writeDictionary;

@end

NS_ASSUME_NONNULL_END
