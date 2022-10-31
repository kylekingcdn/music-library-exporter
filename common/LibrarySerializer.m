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

#import "Logger.h"
#import "OrderedDictionary.h"
#import "Utils.h"
#import "ExportConfiguration.h"
#import "LibraryFilter.h"


@implementation LibrarySerializer {

  ITLibrary* _library;

  NSUInteger _currentEntityId;
  NSMutableDictionary* _entityIdsDict;

  // member variables stored at run-time to handle filtering content
  BOOL shouldRemapTrackLocations;
}


#pragma mark - Initializers

- (instancetype)initWithLibrary:(ITLibrary*)library {

  self = [super init];

  _library = library;

  return self;
}


#pragma mark - Accessors

- (NSString*)remapRootMusicDirForFilePath:(NSString*)filePath {

  return [filePath stringByReplacingOccurrencesOfString:ExportConfiguration.sharedConfig.remapRootDirectoryOriginalPath
                                             withString:ExportConfiguration.sharedConfig.remapRootDirectoryMappedPath];
}

- (nullable NSNumber*)idForEntity:(ITLibMediaEntity*)entity {

  return [_entityIdsDict objectForKey:entity.persistentID];
}


#pragma mark - Mutators

- (void)initSerializeMembers {

  MLE_Log_Info(@"LibrarySerializer [initSerializeMembers]");

  _entityIdsDict = [NSMutableDictionary dictionary];
  _currentEntityId = 0;

  shouldRemapTrackLocations = (ExportConfiguration.sharedConfig.remapRootDirectory &&
                               ExportConfiguration.sharedConfig.remapRootDirectoryOriginalPath.length > 0 &&
                               ExportConfiguration.sharedConfig.remapRootDirectoryMappedPath.length > 0);
}

- (NSNumber*)addEntityToIdDict:(ITLibMediaEntity*)mediaEntity {

  NSUInteger entityId = ++_currentEntityId;
  NSNumber* entityIdNum = [NSNumber numberWithUnsignedInteger:entityId];

  [_entityIdsDict setObject:entityIdNum forKey:mediaEntity.persistentID];

  return entityIdNum;
}

- (OrderedDictionary*)serializeLibraryforTracks:(OrderedDictionary*)tracks andPlaylists:(NSArray<OrderedDictionary*>*)playlists {

  MLE_Log_Info(@"LibrarySerializer [serializeLibraryforTracks:(%lu) andPlaylists:(%lu)]", tracks.count, playlists.count);

  MutableOrderedDictionary* libraryDict = [MutableOrderedDictionary dictionary];

  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.apiMajorVersion] forKey:@"Major Version"];
  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.apiMinorVersion] forKey:@"Minor Version"];
  [libraryDict setValue:[NSDate date] forKey:@"Date"]; // TODO:finish me
  [libraryDict setValue:_library.applicationVersion forKey:@"Application Version"];
  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:_library.features] forKey:@"Features"];
  [libraryDict setValue:@(_library.showContentRating) forKey:@"Show Content Ratings"];
  [libraryDict setValue:ExportConfiguration.sharedConfig.generatedPersistentLibraryId forKey:@"Library Persistent ID"];
  // FIXME: should remap root library apply to this path as well..?
  if (ExportConfiguration.sharedConfig.musicLibraryPath.length > 0) {
    NSURL* musicLibraryPathUrl = [NSURL fileURLWithPath:ExportConfiguration.sharedConfig.musicLibraryPath];
    [libraryDict setValue:musicLibraryPathUrl.absoluteString forKey:@"Music Folder"];
  }

  // set tracks
  [libraryDict setObject:tracks forKey:@"Tracks"];

  // set playlists
  [libraryDict setObject:playlists forKey:@"Playlists"];

  return libraryDict;
}

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists {

  return [self serializePlaylists:playlists withProgressCallback:nil];
}

- (NSArray<OrderedDictionary*>*)serializePlaylists:(NSArray<ITLibPlaylist*>*)playlists withProgressCallback:(nullable void(^)(NSUInteger,NSUInteger))progressCallback {

  NSMutableArray<OrderedDictionary*>* playlistsArray = [NSMutableArray array];
  NSUInteger playlistCount = playlists.count;
  NSUInteger playlistIndex = 0;

  MLE_Log_Info(@"LibrarySerializer [serializePlaylists:(%lu)]", playlists.count);

  for (ITLibPlaylist* playlist in playlists) {

    if (progressCallback) {
      progressCallback(playlistIndex, playlistCount);
    }

    NSNumber* playlistId = [self addEntityToIdDict:playlist];

    // serialize playlist
    OrderedDictionary* playlistDict = [self serializePlaylist:playlist withId:playlistId];

    // add playlist dictionary object to playlistsArray
    [playlistsArray addObject:playlistDict];

    playlistIndex++;
  }

  return playlistsArray;
}

- (OrderedDictionary*)serializePlaylist:(ITLibPlaylist*)playlistItem withId:(NSNumber*)playlistId {

  NSString* playlistHexId = [Utils hexStringForPersistentId:playlistItem.persistentID];

  MLE_Log_Info(@"LibrarySerializer [serializePlaylist:(%@ - %@)]", playlistItem.name, playlistHexId);

  MutableOrderedDictionary* playlistDict = [MutableOrderedDictionary dictionary];

  [playlistDict setValue:playlistItem.name forKey:@"Name"];
//  [playlistDict setValue:playlistItem. forKey:@"Description"]; - unavailable
  if (playlistItem.master) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Master"];
    [playlistDict setValue:[NSNumber numberWithBool:NO] forKey:@"Visible"];
  }
  [playlistDict setValue:playlistId forKey:@"Playlist ID"];
  [playlistDict setValue:playlistHexId forKey:@"Playlist Persistent ID"];

  if (playlistItem.parentID && !ExportConfiguration.sharedConfig.flattenPlaylistHierarchy) {
    [playlistDict setValue:[Utils hexStringForPersistentId:playlistItem.parentID] forKey:@"Parent Persistent ID"];
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

  NSArray<ITLibMediaItem*>* playlistItems = playlistItem.items;
  PlaylistSortColumnType sortColumn = [ExportConfiguration.sharedConfig playlistCustomSortColumn:playlistHexId];

  // custom sorting
  if (sortColumn != PlaylistSortColumnNull) {

    NSString* sortColumnProperty = [Utils mediaItemPropertyForSortColumn:sortColumn];
    PlaylistSortOrderType sortOrder = [ExportConfiguration.sharedConfig playlistCustomSortOrder:playlistHexId];

    if (sortOrder == PlaylistSortOrderNull) {
      // fallback to ascending
      sortOrder = PlaylistSortOrderAscending;
    }

    playlistItems = [Utils sortMediaItems:playlistItems byProperty:sortColumnProperty withOrder:sortOrder];
  }

  // add playlist items array to playlist dict
  NSArray<OrderedDictionary*>* playlistItemsArray = [self serializePlaylistItems:playlistItems];
  [playlistDict setObject:playlistItemsArray forKey:@"Playlist Items"];

  return playlistDict;
}

- (NSArray<OrderedDictionary*>*)serializePlaylistItems:(NSArray<ITLibMediaItem*>*)playlistItems {

  NSMutableArray<OrderedDictionary*>* playlistItemDictsArray = [NSMutableArray array];

  for (ITLibMediaItem* playlistItem in playlistItems) {

    // ignore excluded media kinds
    if (playlistItem.mediaKind == ITLibMediaItemMediaKindSong) {

      MutableOrderedDictionary* playlistItemDict = [MutableOrderedDictionary dictionary];

      NSNumber* trackId = [self idForEntity:playlistItem];
      NSAssert(trackId != nil, @"trackIds dict returned an invalid value for item: %@", playlistItem.persistentID.stringValue);

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

- (OrderedDictionary*)serializeTracks:(NSArray<ITLibMediaItem*>*)tracks withProgressCallback:(nullable void(^)(NSUInteger,NSUInteger))progressCallback {

  MutableOrderedDictionary* tracksDict = [MutableOrderedDictionary dictionary];
  NSUInteger trackCount = tracks.count;
  NSUInteger currentTrack = 0;
  NSUInteger progressVal = 0;
  NSUInteger callbackInterval = 10;

  MLE_Log_Info(@"LibrarySerializer [serializeTracks:(%lu)]", trackCount);

  MLE_Log_Info(@"LibrarySerializer [serializeTracks] started - %@", [[NSDate date] description]);

  for (ITLibMediaItem* track in tracks) {

    if (progressCallback) {
      if (progressVal == callbackInterval - 1) {
        progressVal = 0;
        progressCallback(currentTrack, trackCount);
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

  if (progressCallback) {
    progressCallback(trackCount, trackCount);
  }

  MLE_Log_Info(@"LibrarySerializer [serializeTracks] finished - %@", [[NSDate date] description]);

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

  [trackDict setValue:[Utils hexStringForPersistentId:trackItem.persistentID] forKey:@"Persistent ID"];

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
      trackFilePath = [self remapRootMusicDirForFilePath:trackFilePath];
    }

    NSString* encodedTrackPath = [[NSURL fileURLWithPath:trackFilePath] absoluteString];
    [trackDict setValue:encodedTrackPath forKey:@"Location"];
  }

  return trackDict;
}

@end
