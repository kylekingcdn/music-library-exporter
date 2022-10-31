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


@implementation LibraryFilter {

  ITLibrary* _library;
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

- (NSSet<NSNumber*>*)getIncludedPlaylistKinds {

  MLE_Log_Info(@"LibraryFilter [getIncludedPlaylistKinds]");

  NSMutableSet<NSNumber*>* includedPlaylistKinds = [NSMutableSet set];

  // add non-distinguished playlist kind
  [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindNone]];

  if (ExportConfiguration.sharedConfig.includeInternalPlaylists) {

    // and internal music playlists
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMusic]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindPurchases]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKind90sMusic]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMyTopRated]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindTop25MostPlayed]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRecentlyPlayed]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRecentlyAdded]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindClassicalMusic]];
    [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindLovedSongs]];
  }

  return includedPlaylistKinds;
}

- (NSArray<ITLibPlaylist*>*)getIncludedPlaylists {

  MLE_Log_Info(@"LibraryFilter [getIncludedPlaylists]");

  NSMutableSet<NSString*>* allExcludedPlaylistIds = [ExportConfiguration.sharedConfig.excludedPlaylistPersistentIds mutableCopy];

  NSSet<NSNumber*>* includedPlaylistKinds = [self getIncludedPlaylistKinds];

  NSMutableArray<ITLibPlaylist*>* includedPlaylists = [NSMutableArray array];

  for (ITLibPlaylist* playlist in _library.allPlaylists) {

    NSString* playlistHexId = [Utils hexStringForPersistentId:playlist.persistentID];

    // ignore excluded playlist kinds
    if ([includedPlaylistKinds containsObject:[NSNumber numberWithUnsignedInteger:playlist.distinguishedKind]] && (!playlist.master || ExportConfiguration.sharedConfig.includeInternalPlaylists)) {

      // ignore folders when flattened
      if (playlist.kind != ITLibPlaylistKindFolder || !ExportConfiguration.sharedConfig.flattenPlaylistHierarchy) {

        // filtering by playlist id is enabled
        if (_filterExcludedPlaylistIds) {
          if ([allExcludedPlaylistIds containsObject:playlistHexId]) {
            MLE_Log_Info(@"LibraryFilter [getIncludedPlaylists] playlist was manually excluded by id: %@ - %@", playlist.name, playlistHexId);
          }
          // if folders are enabled and the playlists parent folder is excluded, exclude it as well
          else if (!ExportConfiguration.sharedConfig.flattenPlaylistHierarchy && playlist.parentID != nil && [allExcludedPlaylistIds containsObject:[Utils hexStringForPersistentId:playlist.parentID]]) {
            MLE_Log_Info(@"LibraryFilter [getIncludedPlaylists] parent for playlist was excluded: %@ - %@ (parent: %@)", playlist.name, playlistHexId, [Utils hexStringForPersistentId:playlist.parentID]);
            [allExcludedPlaylistIds addObject:playlistHexId];
          }
          else {
            [includedPlaylists addObject:playlist];
          }
        }
        else {
          [includedPlaylists addObject:playlist];
        }
      }
      else {
        MLE_Log_Info(@"LibraryFilter [getIncludedPlaylists] excluding folder due to flattened hierarchy : %@ - %@", playlist.name, playlistHexId);
      }
    }
    else {
     MLE_Log_Info(@"LibraryFilter [getIncludedPlaylists] excluding internal playlist: %@ - %@", playlist.name, playlistHexId);
    }
  }

  return includedPlaylists;
}

- (NSArray<ITLibMediaItem*>*)getIncludedTracks {

  NSMutableArray<ITLibMediaItem*>* includedTracks = [NSMutableArray array];

  for (ITLibMediaItem* track in _library.allMediaItems) {

    // ignore excluded media kinds
    if (track.mediaKind == ITLibMediaItemMediaKindSong) {

      [includedTracks addObject:track];
    }
  }

  return includedTracks;
}

@end
