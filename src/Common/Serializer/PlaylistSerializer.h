//
//  PlaylistSerializer.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

#import "PlaylistSerializerDelegate.h"

@class ITLibMediaItem;
@class ITLibPlaylist;
@class MediaEntityRepository;
@class MediaItemFilterGroup;
@class OrderedDictionary;
@class PlaylistFilterGroup;

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistSerializer : NSObject

@property (nullable, weak) NSObject<PlaylistSerializerDelegate>* delegate;

@property BOOL flattenFolders;

@property (nullable, weak) PlaylistFilterGroup* playlistFilters;
@property (nullable, weak) MediaItemFilterGroup* itemFilters;

@property (weak) NSDictionary* playlistCustomSortColumns;
@property (weak) NSDictionary* playlistCustomSortOrders;

- (instancetype) init;
- (instancetype) initWithEntityRepository:(MediaEntityRepository*)entityRepository;

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists;
- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlist;

- (NSArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)items;

@end

NS_ASSUME_NONNULL_END
