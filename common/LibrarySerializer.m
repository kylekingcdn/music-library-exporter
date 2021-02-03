//
//  serializer.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import "LibrarySerializer.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "OrderedDictionary.h"
#import "Utils.h"
#import "ExportConfiguration.h"


@implementation LibrarySerializer {

  NSUInteger currentEntityId;
  NSMutableDictionary* entityIdsDicts;

  // member variables stored at run-time to handle filtering content
  NSSet<NSNumber*>* includedPlaylistKinds;
  BOOL shouldRemapTrackLocations;
}


#pragma mark - Utils -

+ (NSString*)getHexadecimalPersistentIdForEntity:(ITLibMediaEntity*)entity {

  return [LibrarySerializer getHexadecimalPersistentId:entity.persistentID];
}

+ (NSString*)getHexadecimalPersistentId:(NSNumber*)decimalPersistentId {

  return [[NSString stringWithFormat:@"%016lx", decimalPersistentId.unsignedIntegerValue] uppercaseString];
}

+ (void)dumpPropertiesForEntity:(ITLibMediaEntity*)entity {

  return [LibrarySerializer dumpPropertiesForEntity:entity withoutProperties:nil];
}

+ (void)dumpPropertiesForEntity:(ITLibMediaEntity*)entity withoutProperties:(NSSet<NSString *> * _Nullable)excludedProperties {

  if (entity) {
    NSLog(@"\n");
    [entity enumerateValuesExceptForProperties:excludedProperties usingBlock:^(NSString * _Nonnull property, id  _Nonnull value, BOOL * _Nonnull stop) {
      NSLog(@"%@: %@", property, value);
    }];
  }
}

+ (void)dumpLibraryPlaylists:(ITLibrary*)library {

  for (ITLibPlaylist* item in library.allPlaylists) {

    ITLibMediaEntity* entity = item;
    [LibrarySerializer dumpPropertiesForEntity:entity withoutProperties:[NSSet setWithObject:ITLibPlaylistPropertyItems]];
  }
}

+ (void)dumpLibraryTracks:(ITLibrary*)library {

  for (ITLibMediaItem* item in library.allMediaItems) {

      ITLibMediaEntity* entity = item;
      [LibrarySerializer dumpPropertiesForEntity:entity];
  }
}


#pragma mark - Accessors -

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath {

  return [filePath stringByReplacingOccurrencesOfString:_configuration.remapRootDirectoryOriginalPath withString:_configuration.remapRootDirectoryMappedPath];
}

- (NSArray<ITLibPlaylist*>*)includedPlaylists {

  NSMutableArray<ITLibPlaylist*>* includedPlaylists = [NSMutableArray array];

  for (ITLibPlaylist* playlist in _library.allPlaylists) {

    // ignore excluded playlist kinds
    if ([includedPlaylistKinds containsObject:[NSNumber numberWithUnsignedInteger:playlist.distinguishedKind]] && (!playlist.master || _configuration.includeInternalPlaylists)) {

      // ignore folders when flattened
      if (playlist.kind != ITLibPlaylistKindFolder || !_configuration.flattenPlaylistHierarchy) {

        // ignore playlists that have been manually marked for exclusion
        if (![_configuration.excludedPlaylistPersistentIds containsObject:playlist.persistentID]) {

          [includedPlaylists addObject:playlist];
        }
        else {
          NSLog(@"playlist was manually excluded by id: %@ - %@", playlist.name, playlist.persistentID);
        }
      }
      else {
        NSLog(@"excluding folder due to flattened hierarchy : %@ - %@", playlist.name, playlist.persistentID);
      }
    }
    else {
     NSLog(@"excluding internal playlist: %@ - %@", playlist.name, playlist.persistentID);
    }
  }

  return includedPlaylists;
}

- (NSArray<ITLibMediaItem*>*)includedTracks {

  NSMutableArray<ITLibMediaItem*>* includedTracks = [NSMutableArray array];

  for (ITLibMediaItem* track in _library.allMediaItems) {

    // ignore excluded media kinds
    if (track.mediaKind == ITLibMediaItemMediaKindSong) {

      [includedTracks addObject:track];
    }
  }

  return includedTracks;
}

#pragma mark - Mutators -

- (NSNumber*)addEntityToIdDict:(ITLibMediaEntity*)mediaEntity {

  NSUInteger entityId = ++currentEntityId;
  NSNumber* entityIdNum = [NSNumber numberWithUnsignedInteger:entityId];

  [entityIdsDicts setValue:entityIdNum forKey:[mediaEntity.persistentID stringValue]];

  return entityIdNum;
}

- (void)initSerializeMembers {

  NSLog(@"[LibrarySerializer initSerializeMembers]");

  currentEntityId = 0;
  entityIdsDicts = [NSMutableDictionary dictionary];

  shouldRemapTrackLocations = (_configuration.remapRootDirectory && _configuration.remapRootDirectoryOriginalPath.length > 0 && _configuration.remapRootDirectoryMappedPath.length > 0);

  [self initIncludedPlaylistKindsDict];
}

// TODO: remove non-music
- (void)initIncludedPlaylistKindsDict {

  NSLog(@"[LibrarySerializer initIncludedPlaylistKindsDict]");

  NSMutableSet<NSNumber*>* playlistKinds = [NSMutableSet set];

  // add non-distinguished playlist kind
  [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindNone]];
  [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMusic]];

  if (_configuration.includeInternalPlaylists) {

    // and internal music playlists
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindPurchases]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKind90sMusic]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMyTopRated]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindTop25MostPlayed]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRecentlyPlayed]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRecentlyAdded]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindClassicalMusic]];
    [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindLovedSongs]];

//    // add internal non-music playlists
//    if (!_musicOnly) {
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMovies]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindTVShows]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindAudiobooks]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindBooks]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRingtones]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindPodcasts]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindVoiceMemos]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindiTunesU]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMusicVideos]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindLibraryMusicVideos]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindHomeVideos]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindApplications]];
//      [playlistKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMusicShowsAndMovies]];
//    }
  }

  includedPlaylistKinds = [playlistKinds copy];
}

- (BOOL)serializeLibrary {

  if (!_library) {
    NSLog(@"LibrarySerializer [serializeLibrary] error - library is nil");
    return NO;
  }
  if (!_configuration) {
    NSLog(@"LibrarySerializer [serializeLibrary] error - configuration is nil");
    return NO;
  }

  NSLog(@"[serializeLibrary]");

  // clear generated library dictionary
  _libraryDict = [MutableOrderedDictionary dictionary];

  // reset serialize member variables
  [self initSerializeMembers];

  [_libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.apiMajorVersion] forKey:@"Major Version"];
  [_libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.apiMinorVersion] forKey:@"Minor Version"];
  [_libraryDict setValue:[NSDate date] forKey:@"Date"]; // TODO:finish me
  [_libraryDict setValue:_library.applicationVersion forKey:@"Application Version"];
  [_libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.features] forKey:@"Features"];
  [_libraryDict setValue:@(_library.showContentRating) forKey:@"Show Content Ratings"];
  // FIXME: should remap root library apply to this path as well..?
  if (_configuration.musicLibraryPath.length > 0) {
    [_libraryDict setValue:_configuration.musicLibraryPath forKey:@"Music Folder"];
  }
//  [dictionary setValue:library.persistentID forKey:@"Library Persistent ID"]; - unavailable

  // add tracks dictionary to library dictionary
  NSArray<ITLibMediaItem*>* includedTracks = [self includedTracks];
  OrderedDictionary* tracksDict = [self serializeTracks:includedTracks];
  [_libraryDict setObject:tracksDict forKey:@"Tracks"];

  // add playlists array to library dictionary
  NSArray<ITLibPlaylist*>* includedPlaylists = [self includedPlaylists];
  NSMutableArray<OrderedDictionary*>* playlistsArray = [self serializePlaylists:includedPlaylists];
  [_libraryDict setObject:playlistsArray forKey:@"Playlists"];

  return YES;
}

- (NSMutableArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists {

  NSLog(@"[LibrarySerializer serializePlaylists:(%lu)]", playlists.count);

  NSMutableArray<OrderedDictionary*>* playlistsArray = [NSMutableArray array];

  for (ITLibPlaylist* playlist in playlists) {

    NSNumber* playlistId = [self addEntityToIdDict:playlist];

    // serialize playlist
    OrderedDictionary* playlistDict = [self serializePlaylist:playlist withId:playlistId];

    // add playlist dictionary object to playlistsArray
    [playlistsArray addObject:playlistDict];
  }

  return playlistsArray;
}

- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSNumber*)playlistId {

  NSLog(@"[LibrarySerializer serializePlaylist:(%@ - %@)]", playlistItem.name, [LibrarySerializer getHexadecimalPersistentId:playlistItem.persistentID]);

  MutableOrderedDictionary* playlistDict = [MutableOrderedDictionary dictionary];

  [playlistDict setValue:playlistItem.name forKey:@"Name"];
//  [playlistDict setValue:playlistItem. forKey:@"Description"]; - unavailable
  if (playlistItem.master) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Master"];
    [playlistDict setValue:[NSNumber numberWithBool:NO] forKey:@"Visible"];
  }
  [playlistDict setValue:playlistId forKey:@"Playlist ID"];
  [playlistDict setValue:[LibrarySerializer getHexadecimalPersistentId:playlistItem.persistentID] forKey:@"Playlist Persistent ID"];

  if (playlistItem.parentID > 0 && !_configuration.flattenPlaylistHierarchy) {
    [playlistDict setValue:[LibrarySerializer getHexadecimalPersistentId:playlistItem.parentID] forKey:@"Parent Persistent ID"];
  }
  if (playlistItem.distinguishedKind > ITLibDistinguishedPlaylistKindNone) {
    [playlistDict setValue:[NSNumber numberWithUnsignedInteger:playlistItem.distinguishedKind] forKey:@"Distinguished Kind"];
    if (playlistItem.distinguishedKind == ITLibDistinguishedPlaylistKindMusic) {
      [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Music"];
    }
  }
  if (!playlistItem.visible) {
    [playlistDict setValue:[NSNumber numberWithBool:NO] forKey:@"Visible"];
  }
  [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"All Items"];
  if (playlistItem.kind == ITLibPlaylistKindFolder) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Folder"];
  }

  // add playlist items array to playlist dict
  NSMutableArray<OrderedDictionary*>* playlistItemsArray = [self serializePlaylistItems:playlistItem.items];
  [playlistDict setObject:playlistItemsArray forKey:@"Playlist Items"];

  return playlistDict;
}

- (NSMutableArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)playlistItems {

  NSMutableArray<OrderedDictionary*>* playlistItemDictsArray = [NSMutableArray array];

  for (ITLibMediaItem* playlistItem in playlistItems) {

    // ignore excluded media kinds
    if (playlistItem.mediaKind == ITLibMediaItemMediaKindSong) {

      MutableOrderedDictionary* playlistItemDict = [MutableOrderedDictionary dictionary];

      NSNumber* trackId = [entityIdsDicts valueForKey:[playlistItem.persistentID stringValue]];
      
      NSAssert(trackId, @"trackIds dict returned an invalid value for item: %@", playlistItem.persistentID.stringValue);

      [playlistItemDict setValue:trackId forKey:@"Track ID"];

      // add item dict to playlist items array
      [playlistItemDictsArray addObject:playlistItemDict];
    }
  }

  return playlistItemDictsArray;
}

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks {

  NSLog(@"[LibrarySerializer serializeTracks:(%lu)]", tracks.count);

  MutableOrderedDictionary* tracksDict = [MutableOrderedDictionary dictionary];

  for (ITLibMediaItem* track in tracks) {

    NSNumber* trackId = [self addEntityToIdDict:track];

    OrderedDictionary* trackDict = [self serializeTrack:track withId:trackId];

    // add track dictionary object to root tracks dictionary
    [tracksDict setObject:trackDict forKey:[trackId stringValue]];
  }

  return tracksDict;
}

- (OrderedDictionary*)serializeTrack:(ITLibMediaItem*)trackItem withId:(NSNumber*)trackId {

  MutableOrderedDictionary* trackDict = [MutableOrderedDictionary dictionary];

  [trackDict setValue:trackId forKey:@"Track ID"];
  [trackDict setValue:trackItem.title forKey:@"Name"];
  if (trackItem.artist.name) {
    [trackDict setValue:trackItem.artist.name forKey:@"Artist"];
  }
  if (trackItem.album.albumArtist) {
    [trackDict setValue:trackItem.album.albumArtist forKey:@"Album Artist"];
  }
  if (trackItem.composer.length > 0) {
    [trackDict setValue:trackItem.composer forKey:@"Composer"];
  }
  if (trackItem.album.title.length > 0) {
    [trackDict setValue:trackItem.album.title forKey:@"Album"];
  }
  if (trackItem.grouping) {
    [trackDict setValue:trackItem.grouping forKey:@"Grouping"];
  }
  if (trackItem.genre.length > 0) {
    [trackDict setValue:trackItem.genre forKey:@"Genre"];
  }
  if (trackItem.kind) {
    [trackDict setValue:trackItem.kind forKey:@"Kind"];
  }
  if (trackItem.comments) {
    [trackDict setValue:trackItem.comments forKey:@"Comments"];
  }
  if (trackItem.fileSize > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedLongLong:trackItem.fileSize] forKey:@"Size"];
  }
  if (trackItem.totalTime > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.totalTime] forKey:@"Total Time"];
  }
  if (trackItem.startTime > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.startTime] forKey:@"Start Time"];
  }
  if (trackItem.stopTime > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.stopTime] forKey:@"Stop Time"];
  }
  if (trackItem.album.discNumber > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.album.discNumber] forKey:@"Disc Number"];
  }
  if (trackItem.album.discCount > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.album.discCount] forKey:@"Disc Count"];
  }
  if (trackItem.trackNumber > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.trackNumber] forKey:@"Track Number"];
  }
  if (trackItem.album.trackCount > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.album.trackCount] forKey:@"Track Count"];
  }
  if (trackItem.year > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.year] forKey:@"Year"];
  }
  if (trackItem.beatsPerMinute > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.beatsPerMinute] forKey:@"BPM"];
  }
  if (trackItem.modifiedDate) {
    [trackDict setValue:trackItem.modifiedDate forKey:@"Date Modified"];
  }
  if (trackItem.addedDate) {
    [trackDict setValue:trackItem.addedDate forKey:@"Date Added"];
  }
  if (trackItem.bitrate > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.bitrate] forKey:@"Bit Rate"];
  }
  if (trackItem.sampleRate > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.sampleRate] forKey:@"Sample Rate"];
  }
  if (trackItem.volumeAdjustment != 0) {
    [trackDict setValue:[NSNumber numberWithInteger:trackItem.volumeAdjustment] forKey:@"Volume Adjustment"];
  }
  if (trackItem.album.gapless) {
    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Part Of Gapless Album"];
  }
  if (trackItem.rating != 0) {
    [trackDict setValue:[NSNumber numberWithInteger:trackItem.rating] forKey:@"Rating"];
  }
  if (trackItem.ratingComputed) {
    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Rating Computed"];
  }
  if (trackItem.album.rating != 0) {
    [trackDict setValue:[NSNumber numberWithInteger:trackItem.album.rating] forKey:@"Album Rating"];
  }
  if (trackItem.album.ratingComputed) {
    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Album Rating Computed"];
  }
  if (trackItem.playCount > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.playCount] forKey:@"Play Count"];
  }
  if (trackItem.lastPlayedDate) {
//    [trackDict setValue:[NSNumber numberWithLongLong:trackItem.lastPlayedDate.timeIntervalSince1970+2082844800] forKey:@"Play Date"]; - invalid
    [trackDict setValue:trackItem.lastPlayedDate forKey:@"Play Date UTC"];
  }
  if (trackItem.skipCount > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.skipCount] forKey:@"Skip Count"];
  }
  if (trackItem.skipDate) {
    [trackDict setValue:trackItem.skipDate forKey:@"Skip Date"];
  }
  if (trackItem.releaseDate) {
    [trackDict setValue:trackItem.releaseDate forKey:@"Release Date"];
  }
  if (trackItem.volumeNormalizationEnergy > 0) {
    [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.volumeNormalizationEnergy] forKey:@"Normalization"];
  }
  if (trackItem.album.compilation) {
    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Compilation"];
  }
//  if (trackItem.hasArtworkAvailable) {
//    [trackDict setValue:[NSNumber numberWithUnsignedInteger:1] forKey:@"Artwork Count"]; - unavailable
//  }
  if (trackItem.album.sortTitle) {
    [trackDict setValue:trackItem.album.sortTitle forKey:@"Sort Album"];
  }
  if (trackItem.album.sortAlbumArtist) {
    [trackDict setValue:trackItem.album.sortAlbumArtist forKey:@"Sort Album Artist"];
  }
  if (trackItem.artist.sortName) {
    [trackDict setValue:trackItem.artist.sortName forKey:@"Sort Artist"];
  }
  if (trackItem.sortComposer) {
    [trackDict setValue:trackItem.sortComposer forKey:@"Sort Composer"];
  }
  if (trackItem.sortTitle) {
    [trackDict setValue:trackItem.sortTitle forKey:@"Sort Name"];
  }
  if (trackItem.isUserDisabled) {
    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Disabled"];
  }

  [trackDict setValue:[LibrarySerializer getHexadecimalPersistentId:trackItem.persistentID] forKey:@"Persistent ID"];

  // add boolean attributes for media kind
  switch (trackItem.mediaKind) {
    case ITLibMediaItemMediaKindSong: {
      break;
    }
    case ITLibMediaItemMediaKindAlertTone: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Tone"];
      break;
    }
    case ITLibMediaItemMediaKindAudiobook: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Audiobook"];
      break;
    }
    case ITLibMediaItemMediaKindBook: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Book"];
      break;
    }
    case ITLibMediaItemMediaKindMovie: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Movie"];
      break;
    }
    case ITLibMediaItemMediaKindMusicVideo: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Music Video"];
      break;
    }
    case ITLibMediaItemMediaKindPodcast: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Podcast"];
      break;
    }
    case ITLibMediaItemMediaKindTVShow: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"TV Show"];
      break;
    }
    case ITLibMediaItemMediaKindRingtone: {
      [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Ringtone"];
      break;
    }
    default: {
      break;
    }
  }
//  [trackDict setValue:trackItem.title forKey:@"Track Type"]; - invalid

//  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.fileType] forKey:@"File Type"]; - deprecated
//  if (trackItem.cloud) {
//    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Matched"]; - unavailable
//  }
//  if (trackItem.purchased) {
//    [trackDict setValue:[NSNumber numberWithBool:YES] forKey:@"Purchased"]; - invalid
//  }
  if (trackItem.location) {

    NSString* trackFilePath = trackItem.location.path;

    if (shouldRemapTrackLocations) {
      trackFilePath = [trackFilePath stringByReplacingOccurrencesOfString:_configuration.remapRootDirectoryOriginalPath withString:_configuration.remapRootDirectoryMappedPath];
    }

    NSString* encodedTrackPath = [[NSURL fileURLWithPath:trackFilePath] absoluteString];
    [trackDict setValue:encodedTrackPath forKey:@"Location"];
  }

  return trackDict;
}

- (BOOL)writeDictionary {

  NSLog(@"[LibrarySerializer writeDictionary]");

  if (!_configuration.isOutputFilePathValid) {
    NSLog(@"[LibrarySerializer writeDictionary] error - invalid output dir/filename");
    return NO;
  }

  NSLog(@"[LibrarySerializer writeDictionary] saving dictionary to: %@", _configuration.outputFileUrl);
  BOOL writeSuccess = [_libraryDict writeToURL:_configuration.outputFileUrl atomically:YES];

  if (!writeSuccess) {
    NSLog(@"[LibrarySerializer writeDictionary] error writing dictionary");
    return NO;
  }

  return YES;
}

@end
