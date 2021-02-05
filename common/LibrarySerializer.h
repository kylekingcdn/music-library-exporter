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

@property (readonly) NSArray<ITLibMediaItem*>* includedTracks;
@property (readonly) NSArray<ITLibPlaylist*>* includedPlaylists;


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Utils -

+ (NSString*)getHexadecimalPersistentId:(NSNumber*)decimalPersistentId;


#pragma mark - Accessors -

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath;

- (NSNumber*)idForEntity:(ITLibMediaEntity*)entity;


#pragma mark - Mutators -

- (void)initSerializeMembers;
- (void)initIncludedPlaylistKindsDict;

- (void)determineIncludedPlaylists;
- (void)determineIncludedTracks;

- (void)generateEntityIdsDict;
- (NSNumber*)addEntityToIdDict:(ITLibMediaEntity*)mediaEntity;

- (OrderedDictionary*)serializeLibraryforTracks:(OrderedDictionary*)tracks andPlaylists:(NSArray<OrderedDictionary*>*)playlists;
- (OrderedDictionary*)serializeLibrary;

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists;
- (NSArray<OrderedDictionary*>*)serializeIncludedPlaylists;

- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSNumber*)playlistId;

- (NSArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)trackItems;

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks withProgressCallback:(nullable void(^)(NSUInteger))callback;
- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks;
- (OrderedDictionary*)serializeIncludedTracksWithProgressCallback:(nullable void(^)(NSUInteger))callback;
- (OrderedDictionary*)serializeIncludedTracks;

- (OrderedDictionary*)serializeTrack:(ITLibMediaItem*)trackItem withId:(NSNumber*)trackId;


@end

NS_ASSUME_NONNULL_END
