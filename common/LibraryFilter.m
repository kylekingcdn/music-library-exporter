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

#import "OrderedDictionary.h"
#import "Utils.h"
#import "ExportConfiguration.h"


@implementation LibraryFilter


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  return self;
}


#pragma mark - Accessors -

- (NSSet<NSNumber*>*)getIncludedPlaylistKinds {

  NSLog(@"LibraryFilter [getIncludedPlaylistKinds]");

  NSMutableSet<NSNumber*>* includedPlaylistKinds = [NSMutableSet set];

  // add non-distinguished playlist kind
  [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindNone]];
  [includedPlaylistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMusic]];

  if (_configuration.includeInternalPlaylists) {

    // and internal music playlists
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

  NSLog(@"LibraryFilter [getIncludedPlaylists]");

  NSSet<NSNumber*>* includedPlaylistKinds = [self getIncludedPlaylistKinds];

  NSMutableArray<ITLibPlaylist*>* includedPlaylists = [NSMutableArray array];

  for (ITLibPlaylist* playlist in _library.allPlaylists) {

    // ignore excluded playlist kinds
    if ([includedPlaylistKinds containsObject:[NSNumber numberWithUnsignedInteger:playlist.distinguishedKind]] && (!playlist.master || _configuration.includeInternalPlaylists)) {

      // ignore folders when flattened
      if (playlist.kind != ITLibPlaylistKindFolder || !_configuration.flattenPlaylistHierarchy) {

        // ignore playlists that have been manually marked for exclusion
        if (![_configuration isPlaylistIdExcluded:playlist.persistentID]) {

          [includedPlaylists addObject:playlist];
        }
        else {
          NSLog(@"LibraryFilter [getIncludedPlaylists] playlist was manually excluded by id: %@ - %@", playlist.name, playlist.persistentID);
        }
      }
      else {
        NSLog(@"LibraryFilter [getIncludedPlaylists] excluding folder due to flattened hierarchy : %@ - %@", playlist.name, playlist.persistentID);
      }
    }
    else {
     NSLog(@"LibraryFilter [getIncludedPlaylists] excluding internal playlist: %@ - %@", playlist.name, playlist.persistentID);
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
