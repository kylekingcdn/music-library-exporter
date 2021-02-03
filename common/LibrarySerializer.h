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


#pragma mark - Accessors -

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath;

- (NSArray<ITLibPlaylist*>*)includedPlaylists;
- (NSArray<ITLibMediaItem*>*)includedTracks;


#pragma mark - Mutators -

- (NSNumber*)addEntityToIdDict:(ITLibMediaEntity*)mediaEntity;

- (void)initSerializeMembers;
- (void)initIncludedPlaylistKindsDict;

- (BOOL)serializeLibrary;

- (NSMutableArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists;
- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSNumber*)playlistId;
- (NSMutableArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)trackItems;

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks;
- (OrderedDictionary*)serializeTrack:(ITLibMediaItem*)trackItem withId:(NSNumber*)trackId;

- (BOOL)writeDictionary;

@end

NS_ASSUME_NONNULL_END
