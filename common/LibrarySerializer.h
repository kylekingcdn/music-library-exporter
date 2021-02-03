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
@class OrderedDictionary;
@class MutableOrderedDictionary;
@class ExportConfiguration;


NS_ASSUME_NONNULL_BEGIN

@interface LibrarySerializer : NSObject


#pragma mark - Properties -

@property ITLibrary* library;
@property ExportConfiguration* configuration;

@property (readonly) MutableOrderedDictionary* libraryDict;


#pragma mark - Utils -

+ (NSString*)getHexadecimalPersistentIdForEntity:(ITLibMediaEntity*)entity;
+ (NSString*)getHexadecimalPersistentId:(NSNumber*)decimalPersistentId;

+ (void)dumpPropertiesForEntity:(ITLibMediaEntity*)entity;
+ (void)dumpPropertiesForEntity:(ITLibMediaEntity*)entity withoutProperties:(NSSet<NSString *> * _Nullable)excludedProperties;

+ (void)dumpLibraryPlaylists:(ITLibrary*)library;
+ (void)dumpLibraryTracks:(ITLibrary*)library;


#pragma mark - Accessors -

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath;


#pragma mark - Mutators -

- (void)initSerializeMembers;
- (void)initIncludedMediaKindsDict;
- (void)initIncludedPlaylistKindsDict;

- (BOOL)serializeLibrary;

- (NSMutableArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists;
- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSUInteger)playlistId;
- (NSMutableArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)trackItems;

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks;
- (OrderedDictionary*)serializeTrack:(ITLibMediaItem*)trackItem withId:(NSUInteger)trackId;

- (BOOL)writeDictionary;

@end

NS_ASSUME_NONNULL_END
