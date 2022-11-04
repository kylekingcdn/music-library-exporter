//
//  PlaylistSerializer.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "PlaylistSerializer.h"

#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "Logger.h"
#import "MediaEntityRepository.h"
#import "MediaItemFilterGroup.h"
#import "OrderedDictionary.h"
#import "PlaylistFilterGroup.h"
#import "Utils.h"

@implementation PlaylistSerializer {

  MediaEntityRepository* _entityRepository;
}

- (instancetype) initWithEntityRepository:(MediaEntityRepository*)entityRepository {

  self = [super init];

  _entityRepository = entityRepository;
  _flattenFolders = false;

  return self;
}

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists {

  NSMutableArray<OrderedDictionary*>* playlistsArray = [NSMutableArray array];

  NSUInteger serializedPlaylists = 0;
  NSUInteger totalPlaylists = playlists.count;

  for (ITLibPlaylist* playlist in playlists) {

    // ignore excluded playlists
    if (_playlistFilters == nil || [_playlistFilters filtersPassForPlaylist:playlist]) {

      [playlistsArray addObject:[self serializePlaylist:playlist]];
    }
    else if (_delegate != nil && [_delegate respondsToSelector:@selector(excludedPlaylist:)]) {
      [_delegate excludedPlaylist:playlist];
    }

    serializedPlaylists++;

    if (_delegate != nil && [_delegate respondsToSelector:@selector(serializedPlaylists:ofTotal:)]) {
      [_delegate serializedPlaylists:serializedPlaylists ofTotal:totalPlaylists];
    }
  }

  return playlistsArray;
}

- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlist {

  MutableOrderedDictionary* playlistDict = [MutableOrderedDictionary dictionary];

  [playlistDict setValue:playlist.name forKey:@"Name"];
  /* unavailable
  [playlistDict setValue:playlistItem. forKey:@"Description"]; - unavailable
  */
  if (playlist.master) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Master"];
    [playlistDict setValue:[NSNumber numberWithBool:NO] forKey:@"Visible"];
  }
  [playlistDict setValue:[_entityRepository getIDForEntity:playlist] forKey:@"Playlist ID"];
  [playlistDict setValue:[Utils hexStringForPersistentId:playlist.persistentID] forKey:@"Playlist Persistent ID"];

  if (playlist.parentID && !_flattenFolders) {
    [playlistDict setValue:[Utils hexStringForPersistentId:playlist.parentID] forKey:@"Parent Persistent ID"];
  }
  if (playlist.distinguishedKind > ITLibDistinguishedPlaylistKindNone) {
    [playlistDict setValue:[NSNumber numberWithUnsignedInteger:playlist.distinguishedKind] forKey:@"Distinguished Kind"];
    if (playlist.distinguishedKind == ITLibDistinguishedPlaylistKindMusic) {
      [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Music"];
    }
  }
  if (!playlist.visible) {
    [playlistDict setValue:[NSNumber numberWithBool:NO] forKey:@"Visible"];
  }
  [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"All Items"];
  if (playlist.kind == ITLibPlaylistKindFolder) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Folder"];
  }

  // TODO: handle sorting
  NSArray<ITLibMediaItem*>* sortedItems = playlist.items;
  [playlistDict setObject:[self serializePlaylistItems:sortedItems] forKey:@"Playlist Items"];

  return playlistDict;
}

- (NSArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)items {

  NSMutableArray<OrderedDictionary*>* itemsArray = [NSMutableArray array];

  for (ITLibMediaItem* item in items) {

    // ignore excluded media items
    if (_itemFilters == nil || [_itemFilters filtersPassForItem:item]) {
      
      MutableOrderedDictionary* itemDict = [MutableOrderedDictionary dictionary];
      [itemDict setValue:[_entityRepository getIDForEntity:item] forKey:@"Track ID"];

      [itemsArray addObject:itemDict];
    }
  }

  return itemsArray;
}

@end
