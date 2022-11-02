//
//  PlaylistSerializer.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

@class ITLibMediaItem;
@class ITLibPlaylist;
@class MediaEntityRepository;
@class MediaItemFilterGroup;
@class OrderedDictionary;
@class PlaylistFilterGroup;

NS_ASSUME_NONNULL_BEGIN

@protocol PlaylistSerializerDelegate <NSObject>
@optional

- (void)serializedPlaylists:(NSUInteger)serialized ofTotal:(NSUInteger)total;

@end

@interface PlaylistSerializer : NSObject

@property (nullable, weak) NSObject<PlaylistSerializerDelegate>* delegate;

@property BOOL flattenFolders;

@property (nullable) PlaylistFilterGroup* playlistFilters;
@property (nullable) MediaItemFilterGroup* itemFilters;

- (instancetype) initWithEntityRepository:(MediaEntityRepository*)entityRepository;

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists;
- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlist;

- (NSArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)items;

@end

NS_ASSUME_NONNULL_END
