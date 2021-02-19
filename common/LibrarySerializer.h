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


#pragma mark - Initializers -

- (instancetype)initWithLibrary:(ITLibrary*)library;


#pragma mark - Utils -

+ (NSString*)getHexadecimalPersistentId:(NSNumber*)decimalPersistentId;


#pragma mark - Accessors -

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath;

- (nullable NSNumber*)idForEntity:(ITLibMediaEntity*)entity;


#pragma mark - Mutators -

- (void)initSerializeMembers;

- (NSNumber*)addEntityToIdDict:(ITLibMediaEntity*)mediaEntity;

- (OrderedDictionary*)serializeLibraryforTracks:(OrderedDictionary*)tracks andPlaylists:(NSArray<OrderedDictionary*>*)playlists;

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists;
- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSNumber*)playlistId;

- (NSArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)trackItems;

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks withProgressCallback:(nullable void(^)(NSUInteger,NSUInteger))progressCallback;
- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks;
- (OrderedDictionary*)serializeTrack:(ITLibMediaItem*)trackItem withId:(NSNumber*)trackId;


@end

NS_ASSUME_NONNULL_END
