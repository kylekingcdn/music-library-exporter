//
//  LibraryFilter.m
//  library-generator
//
//  Created by Kyle King on 2021-02-04.
//

#import "LibraryFilter.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "Logger.h"
#import "OrderedDictionary.h"
#import "Utils.h"
#import "ExportConfiguration.h"
#import "MediaItemKindFilter.h"
#import "MediaItemFilterGroup.h"
#import "PlaylistKindFilter.h"
#import "PlaylistDistinguishedKindFilter.h"
#import "PlaylistMasterFilter.h"
#import "PlaylistIDFilter.h"
#import "PlaylistParentIDFilter.h"
#import "PlaylistFilterGroup.h"

@implementation LibraryFilter {

  ITLibrary* _library;
  MediaItemFilterGroup* _mediaItemFilters;
  PlaylistFilterGroup* _playlistFilters;
  PlaylistParentIDFilter* _playlistParentIDFilter;
}


#pragma mark - Initializers

- (instancetype)initWithLibrary:(ITLibrary*)library {

  self = [super init];

  _library = library;

  [self setFilterExcludedPlaylistIds:YES];

  return self;
}


- (instancetype)init {

  self = [super init];

  return self;
}


#pragma mark - Accessors

- (NSArray<ITLibMediaItem*>*)getIncludedMediaItems {

  [self initMediaItemFilters];

  NSMutableArray<ITLibMediaItem*>* includedMediaItems = [NSMutableArray array];

  for (ITLibMediaItem* mediaItem in _library.allMediaItems) {

    // include media item
    if ([_mediaItemFilters filtersPassForItem:mediaItem]) {
      [includedMediaItems addObject:mediaItem];
    }
  }

  return includedMediaItems;
}

- (NSArray<ITLibPlaylist*>*)getIncludedPlaylists {

  [self initPlaylistFilters];

  NSMutableArray<ITLibPlaylist*>* includedPlaylists = [NSMutableArray array];

  for (ITLibPlaylist* playlist in _library.allPlaylists) {

    // include playlist
    if ([_playlistFilters filtersPassForPlaylist:playlist]) {
      [includedPlaylists addObject:playlist];
    }
    // exclude playlist
    else {
      // add playlist to excluded parent playlist filter
      [_playlistParentIDFilter addExcludedID:playlist.persistentID];
    }
  }

  return includedPlaylists;
}


#pragma mark - Mutators

- (void)initMediaItemFilters {

  MediaItemKindFilter* mediaItemKindFilter = [[MediaItemKindFilter alloc] init];
  [mediaItemKindFilter addKind:ITLibMediaItemMediaKindSong];

  _mediaItemFilters = [[MediaItemFilterGroup alloc] init];
  [_mediaItemFilters addFilter:mediaItemKindFilter];
}

- (void)initPlaylistFilters {

  _playlistFilters = [[PlaylistFilterGroup alloc] init];

  PlaylistDistinguishedKindFilter* playlistDistinguishedKindFilter = [[PlaylistDistinguishedKindFilter alloc] init];
  [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindNone];

  PlaylistKindFilter* playlistKindFilter = [[PlaylistKindFilter alloc] init];
  [playlistKindFilter addKind:ITLibPlaylistKindRegular];
  [playlistKindFilter addKind:ITLibPlaylistKindSmart];

  // include folders
  if (!ExportConfiguration.sharedConfig.flattenPlaylistHierarchy) {
    [playlistKindFilter addKind:ITLibPlaylistKindFolder];
  }

  [_playlistFilters addFilter:playlistKindFilter];

  // exclude internal playlists
  if (!ExportConfiguration.sharedConfig.includeInternalPlaylists) {

    [_playlistFilters addFilter:[[PlaylistMasterFilter alloc] init]];
  }
  // include internal playlists
  else {
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindMusic];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindPurchases];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKind90sMusic];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindMyTopRated];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindTop25MostPlayed];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindRecentlyPlayed];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindRecentlyAdded];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindClassicalMusic];
    [playlistDistinguishedKindFilter addKind:ITLibDistinguishedPlaylistKindLovedSongs];
  }

  [_playlistFilters addFilter:playlistDistinguishedKindFilter];

  PlaylistIDFilter* playlistIDFilter = [[PlaylistIDFilter alloc] initWithExcludedIDs:ExportConfiguration.sharedConfig.excludedPlaylistPersistentIds];
  _playlistParentIDFilter = [[PlaylistParentIDFilter alloc] initWithExcludedIDs:ExportConfiguration.sharedConfig.excludedPlaylistPersistentIds];

  if (_filterExcludedPlaylistIds) {
    [_playlistFilters addFilter:playlistIDFilter];

    // don't include children when a parent playlist is excluded
    if (!ExportConfiguration.sharedConfig.flattenPlaylistHierarchy) {
      [_playlistFilters addFilter:_playlistParentIDFilter];
    }
  }
}

@end
