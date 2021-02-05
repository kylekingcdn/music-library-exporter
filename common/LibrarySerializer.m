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

  NSUInteger _currentEntityId;
  NSMutableDictionary* _entityIdsDict;

  // member variables stored at run-time to handle filtering content
  NSSet<NSNumber*>* includedPlaylistKinds;
  BOOL shouldRemapTrackLocations;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  return self;
}


#pragma mark - Utils -

+ (NSString*)getHexadecimalPersistentId:(NSNumber*)decimalPersistentId {

  return [[NSString stringWithFormat:@"%016lx", decimalPersistentId.unsignedIntegerValue] uppercaseString];
}


#pragma mark - Accessors -

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath {

  return [filePath stringByReplacingOccurrencesOfString:_configuration.remapRootDirectoryOriginalPath withString:_configuration.remapRootDirectoryMappedPath];
}

- (NSNumber*)idForEntity:(ITLibMediaEntity*)entity {

  return [_entityIdsDict valueForKey:[entity.persistentID stringValue]];
}


#pragma mark - Mutators -

- (void)initSerializeMembers {

  NSLog(@"LibrarySerializer [initSerializeMembers]");

  _entityIdsDict = [NSMutableDictionary dictionary];
  _currentEntityId = 0;

  shouldRemapTrackLocations = (_configuration.remapRootDirectory && _configuration.remapRootDirectoryOriginalPath.length > 0 && _configuration.remapRootDirectoryMappedPath.length > 0);

  [self initIncludedPlaylistKindsDict];
}

- (void)initIncludedPlaylistKindsDict {

  NSLog(@"LibrarySerializer [initIncludedPlaylistKindsDict]");

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
  }

  includedPlaylistKinds = [playlistKinds copy];
}

- (void)determineIncludedPlaylists {

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
          NSLog(@"LibrarySerializer [includedPlaylists] playlist was manually excluded by id: %@ - %@", playlist.name, playlist.persistentID);
        }
      }
      else {
        NSLog(@"LibrarySerializer [includedPlaylists] excluding folder due to flattened hierarchy : %@ - %@", playlist.name, playlist.persistentID);
      }
    }
    else {
     NSLog(@"LibrarySerializer [includedPlaylists] excluding internal playlist: %@ - %@", playlist.name, playlist.persistentID);
    }
  }

  _includedPlaylists = includedPlaylists;
}

- (void)determineIncludedTracks {

  NSMutableArray<ITLibMediaItem*>* includedTracks = [NSMutableArray array];

  for (ITLibMediaItem* track in _library.allMediaItems) {

    // ignore excluded media kinds
    if (track.mediaKind == ITLibMediaItemMediaKindSong) {

      [includedTracks addObject:track];
    }
  }

  _includedTracks = includedTracks;
}

- (NSNumber*)addEntityToIdDict:(ITLibMediaEntity*)mediaEntity {

  NSUInteger entityId = ++_currentEntityId;
  NSNumber* entityIdNum = [NSNumber numberWithUnsignedInteger:entityId];

  [_entityIdsDict setValue:entityIdNum forKey:[mediaEntity.persistentID stringValue]];

  return entityIdNum;
}

- (OrderedDictionary*)serializeLibraryforTracks:(OrderedDictionary*)tracks andPlaylists:(NSArray<OrderedDictionary*>*)playlists {

  NSLog(@"LibrarySerializer [serializeLibraryforTracks:(%lu) andPlaylists:(%lu)]", tracks.count, playlists.count);

  MutableOrderedDictionary* libraryDict = [MutableOrderedDictionary dictionary];

  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.apiMajorVersion] forKey:@"Major Version"];
  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.apiMinorVersion] forKey:@"Minor Version"];
  [libraryDict setValue:[NSDate date] forKey:@"Date"]; // TODO:finish me
  [libraryDict setValue:_library.applicationVersion forKey:@"Application Version"];
  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.features] forKey:@"Features"];
  [libraryDict setValue:@(_library.showContentRating) forKey:@"Show Content Ratings"];
  // FIXME: should remap root library apply to this path as well..?
  if (_configuration.musicLibraryPath.length > 0) {
    [libraryDict setValue:_configuration.musicLibraryPath forKey:@"Music Folder"];
  }

  // set tracks
  [libraryDict setObject:tracks forKey:@"Tracks"];

  // set playlists
  [libraryDict setObject:playlists forKey:@"Playlists"];

  return libraryDict;
}

- (OrderedDictionary*)serializeLibrary {

  return [self serializeLibraryforTracks:[self serializeTracks:_includedTracks]
                            andPlaylists:[self serializePlaylists:_includedPlaylists]];
}

- (NSMutableArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists {

  NSLog(@"LibrarySerializer [serializePlaylists:(%lu)]", playlists.count);

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

- (NSArray<OrderedDictionary*>*)serializeIncludedPlaylists {

  return [self serializePlaylists:_includedPlaylists];
}

- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSNumber*)playlistId {

  NSLog(@"LibrarySerializer [serializePlaylist:(%@ - %@)]", playlistItem.name, [LibrarySerializer getHexadecimalPersistentId:playlistItem.persistentID]);

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
  NSArray<OrderedDictionary*>* playlistItemsArray = [self serializePlaylistItems:playlistItem.items];
  [playlistDict setObject:playlistItemsArray forKey:@"Playlist Items"];

  return playlistDict;
}

- (NSMutableArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)playlistItems {

  NSMutableArray<OrderedDictionary*>* playlistItemDictsArray = [NSMutableArray array];

  for (ITLibMediaItem* playlistItem in playlistItems) {

    // ignore excluded media kinds
    if (playlistItem.mediaKind == ITLibMediaItemMediaKindSong) {

      MutableOrderedDictionary* playlistItemDict = [MutableOrderedDictionary dictionary];

      NSNumber* trackId = [self idForEntity:playlistItem];
      NSAssert(trackId, @"trackIds dict returned an invalid value for item: %@", playlistItem.persistentID.stringValue);

      [playlistItemDict setValue:trackId forKey:@"Track ID"];

      // add item dict to playlist items array
      [playlistItemDictsArray addObject:playlistItemDict];
    }
  }

  return playlistItemDictsArray;
}

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks {

  return [self serializeTracks:tracks withProgressCallback:nil];
}

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks withProgressCallback:(nullable void(^)(NSUInteger))callback {

  MutableOrderedDictionary* tracksDict = [MutableOrderedDictionary dictionary];
  NSUInteger trackCount = tracks.count;
  NSUInteger currentTrack = 0;
  NSUInteger progressVal = 0;
  NSUInteger callbackInterval = 10;

  NSLog(@"LibrarySerializer [serializeTracks:(%lu)]", trackCount);

  NSLog(@"LibrarySerializer [serializeTracks] started - %@", [[NSDate date] description]);

  for (ITLibMediaItem* track in tracks) {

    if (callback) {
      if (progressVal == callbackInterval - 1) {
        progressVal = 0;
        callback(currentTrack);
      }
      else {
        progressVal++;
      }
    }

    NSNumber* trackId = [self addEntityToIdDict:track];

    OrderedDictionary* trackDict = [self serializeTrack:track withId:trackId];

    // add track dictionary object to root tracks dictionary
    [tracksDict setObject:trackDict forKey:[trackId stringValue]];

    currentTrack++;
  }

  if (callback) {
    callback(trackCount);
  }

  NSLog(@"LibrarySerializer [serializeTracks] finished - %@", [[NSDate date] description]);

  return tracksDict;
}
- (OrderedDictionary*)serializeIncludedTracks {

  return [self serializeTracks:_includedTracks];
}

- (OrderedDictionary*)serializeIncludedTracksWithProgressCallback:(nullable void(^)(NSUInteger))callback {

  return [self serializeTracks:_includedTracks withProgressCallback:callback];
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

@end
