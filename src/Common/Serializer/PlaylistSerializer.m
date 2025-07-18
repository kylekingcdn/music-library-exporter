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
#import "MediaItemSorter.h"
#import "OrderedDictionary.h"
#import "PlaylistFilterGroup.h"
#import "Utils.h"

@implementation PlaylistSerializer {

  MediaEntityRepository* _entityRepository;
}

- (instancetype)init {

  if (self = [super init]) {

    _delegate = nil;

    _flattenFolders = false;

    _playlistFilters = nil;
    _itemFilters = nil;

    _playlistCustomSortProperties = [NSDictionary dictionary];
    _playlistCustomSortOrders = [NSDictionary dictionary];

    _entityRepository = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype) initWithEntityRepository:(MediaEntityRepository*)entityRepository {

  if (self = [self init]) {

    _entityRepository = entityRepository;

    return self;
  }
  else {
    return nil;
  }
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

  os_log_info(OS_LOG_DEFAULT, "Serializing playlist: '%{public}@' (kind: %{public}@)", playlist.name, [PlaylistSerializer describePlaylistKind:playlist.kind]);

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

  MediaItemSorter* sorter = nil;

  if (_playlistCustomSortProperties != nil && _playlistCustomSortProperties != nil) {

    NSString* sortProperty = [_playlistCustomSortProperties valueForKey:[Utils hexStringForPersistentId:playlist.persistentID]];

    NSString* sortOrderTitle = [_playlistCustomSortOrders valueForKey:[Utils hexStringForPersistentId:playlist.persistentID]];
    PlaylistSortOrderType sortOrder = [Utils playlistSortOrderForTitle:sortOrderTitle];

    sorter = [[MediaItemSorter alloc] initWithSortProperty:sortProperty andSortOrder:sortOrder];
  }
  else {
    sorter = [[MediaItemSorter alloc] init];
  }

  NSArray<ITLibMediaItem*>* sortedItems = [sorter sortItems:playlist.items];
  os_log_info(OS_LOG_DEFAULT, "Starting serialization of %lu child items in playlist: '%{public}@' (kind: %{public}@)", sortedItems.count, playlist.name, [PlaylistSerializer describePlaylistKind:playlist.kind]);
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

+ (nonnull NSString *)describePlaylistKind:(ITLibPlaylistKind)kind { 
  switch (kind) {
    case ITLibPlaylistKindRegular: {
      return @"Playlist";
    }
    case ITLibPlaylistKindSmart: {
      return @"Smart Playlist";
    }
    case ITLibPlaylistKindGenius: {
      return @"Genius";
    }
    case ITLibPlaylistKindFolder: {
      return @"Folder";
    }
    case ITLibPlaylistKindGeniusMix: {
      return @"Genius Mix";
    }
  }
}

@end
