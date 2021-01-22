//
//  serializer.m
//  itunesxmlgen
//
//  Created by Kyle King on 2021-01-18.
//

#import "LibrarySerializer.h"

#import "Utils.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibPlaylist.h>

@implementation LibrarySerializer

+ (NSString*) getHexadecimalPersistentId:(NSNumber*)decimalPersistentId {

  return [[NSString stringWithFormat:@"%0lx", decimalPersistentId.unsignedIntegerValue] uppercaseString];
}

+ (void) dumpPropertiesForEntity:(ITLibMediaEntity*) entity {

  return [LibrarySerializer dumpPropertiesForEntity:entity withoutProperties:nil];
}

+ (void) dumpPropertiesForEntity:(ITLibMediaEntity*) entity withoutProperties:(NSSet<NSString *> * _Nullable) excludedProperties {

  if (entity) {
    NSLog(@"\n");
    [entity enumerateValuesExceptForProperties:excludedProperties usingBlock:^(NSString * _Nonnull property, id  _Nonnull value, BOOL * _Nonnull stop) {
      NSLog(@"%@: %@", property, value);
    }];
  }
}

+ (void) dumpLibraryPlaylists:(ITLibrary*) library {

  for (ITLibPlaylist* item in library.allPlaylists) {

    ITLibMediaEntity* entity = item;
    [LibrarySerializer dumpPropertiesForEntity:entity withoutProperties:[NSSet setWithObject:ITLibPlaylistPropertyItems]];
  }
}

+ (void) dumpLibraryTracks:(ITLibrary*) library {

  for (ITLibMediaItem* item in library.allMediaItems) {

      ITLibMediaEntity* entity = item;
      [LibrarySerializer dumpPropertiesForEntity:entity];
  }
}

- (void) serializeLibrary:(ITLibrary*) library {

  NSLog(@"[LibrarySerializer serializeLibrary]");

  lastId = 1;
  _dictionary = [NSMutableDictionary dictionary];

  [_dictionary setValue:[NSNumber numberWithUnsignedInteger:library.apiMajorVersion] forKey:@"Major Version"];
  [_dictionary setValue:[NSNumber numberWithUnsignedInteger:library.apiMinorVersion] forKey:@"Minor Version"];
  [_dictionary setValue:[NSDate date] forKey:@"Date"]; // TODO:finish me
  [_dictionary setValue:library.applicationVersion forKey:@"Application Version"];
  [_dictionary setValue:[NSNumber numberWithUnsignedInteger:library.features] forKey:@"Features"];
  [_dictionary setValue:@(library.showContentRating) forKey:@"Show Content Ratings"];
  [_dictionary setValue:library.mediaFolderLocation.absoluteString forKey:@"Music Folder"];
  //[dictionary setValue:library.persistentID forKey:@"Library Persistent ID"]; // Not available

  // add tracks dictionary to library dictionary
  NSMutableDictionary* tracksDict = [self serializeTracks:library.allMediaItems];
  [_dictionary setObject:tracksDict forKey:@"Tracks"];

  // add playlists array to library dictionary
  NSMutableArray<NSMutableDictionary*>* playlistsArray = [self serializePlaylists:library.allPlaylists];
  [_dictionary setObject:playlistsArray forKey:@"Playlists"];
}

- (NSMutableArray<NSMutableDictionary*>*) serializePlaylists:(NSArray<ITLibPlaylist*>*) playlists {

  NSMutableArray<NSMutableDictionary*>* playlistsArray = [NSMutableArray array];

  // clear playlist ids dictionary
  playlistIdsDict = [NSMutableDictionary dictionary];

  for (ITLibPlaylist* playlistItem in playlists) {

    // generate playlist id
    NSUInteger playlistId = lastId;
    lastId++;

    // store playlist + id in playlistIds dict
    NSString* playlistPersistentIdHex = [LibrarySerializer getHexadecimalPersistentId:playlistItem.persistentID];
    NSNumber* playlistIdNumber = [NSNumber numberWithUnsignedInteger:playlistId];
    [playlistIdsDict setValue:playlistIdNumber forKey:playlistPersistentIdHex];

    // serialize playlist
    NSMutableDictionary* playlistDict = [self serializePlaylist:playlistItem withId:playlistId];

    // add playlist dictionary object to playlistsArray
    [playlistsArray addObject:playlistDict];
  }

  return playlistsArray;
}

- (NSMutableDictionary*) serializePlaylist:(ITLibPlaylist*) playlistItem withId: (NSUInteger) playlistId {

  NSMutableDictionary* playlistDict = [NSMutableDictionary dictionary];

  [playlistDict setValue:playlistItem.name forKey:@"Name"];
  /*[playlistDict setValue:playlistItem. forKey:@"Description"];*/ // unavailable
  if (playlistItem.master) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Master"];  // optional
  }
  [playlistDict setValue:[NSNumber numberWithInteger:playlistId] forKey:@"Playlist ID"];
  [playlistDict setValue:[LibrarySerializer getHexadecimalPersistentId:playlistItem.persistentID] forKey:@"Playlist Persistent ID"];
  if (playlistItem.parentID > 0) {
    [playlistDict setValue:[LibrarySerializer getHexadecimalPersistentId:playlistItem.parentID] forKey:@"Parent Persistent ID"];  // optional
  }
  if (playlistItem.distinguishedKind > ITLibDistinguishedPlaylistKindNone) {
    [playlistDict setValue:[NSNumber numberWithUnsignedInteger:playlistItem.distinguishedKind] forKey:@"Distinguished Kind"];  // optional
  }
  if (playlistItem.distinguishedKind == ITLibDistinguishedPlaylistKindMusic) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Music"];  // optional
  }
  if (playlistItem.visible) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Visible"];  // optional
  }
  [playlistDict setValue:[NSNumber numberWithBool:playlistItem.allItemsPlaylist] forKey:@"All Items"];
  if (playlistItem.kind == ITLibPlaylistKindFolder) {
    [playlistDict setValue:[NSNumber numberWithBool:YES] forKey:@"Folder"];  // optional
  }

  // add playlist items array to playlist dict
  NSMutableArray<NSMutableDictionary*>* playlistItemsArray = [self serializePlaylistItems:playlistItem.items];
  [playlistDict setObject:playlistItemsArray forKey:@"Playlist Items"];

  return playlistDict;
}

- (NSMutableArray<NSMutableDictionary*>*) serializePlaylistItems: (NSArray<ITLibMediaItem*>*) trackItems {

  NSMutableArray<NSMutableDictionary*>* playlistItemsArray = [NSMutableArray array];

  for (ITLibMediaItem* trackItem in trackItems) {

    if (trackItem.mediaKind == ITLibMediaItemMediaKindSong) {

      NSMutableDictionary* playlistItemDict = [NSMutableDictionary dictionary];

      // get track id
      NSString* trackPersistentId = [LibrarySerializer getHexadecimalPersistentId:trackItem.persistentID];
      NSAssert([[trackIdsDict allKeys] containsObject:trackPersistentId], @"trackIds doesn't contain persistent ID for track '%@'", trackPersistentId);
      NSUInteger trackId = [[trackIdsDict objectForKey:trackPersistentId] integerValue];
      NSAssert(trackId > 0, @"trackIds dict returned an invalid value: %lu", trackId);

      [playlistItemDict setValue:[NSNumber numberWithUnsignedInteger:trackId] forKey:@"Track ID"];

      // add item dict to playlist items array
      [playlistItemsArray addObject:playlistItemDict];
    }
  }

  return playlistItemsArray;
}

- (NSMutableDictionary*) serializeTracks:(NSArray<ITLibMediaItem*>*) tracks {

  NSMutableDictionary* tracksDict = [NSMutableDictionary dictionary];

  // clear track ids dictionary
  trackIdsDict = [NSMutableDictionary dictionary];

  for (ITLibMediaItem* trackItem in tracks) {

    if (trackItem.mediaKind == ITLibMediaItemMediaKindSong) {

      // generate track id
      NSUInteger trackId = lastId;
      lastId++;

      // store track + id in trackIds dict
      NSString* trackPersistentIdHex = [LibrarySerializer getHexadecimalPersistentId:trackItem.persistentID];
//      NSNumber* trackIdString = [NSNumber numberWithUnsignedInteger:trackId];
      NSString* trackIdString = [@(trackId) stringValue];
      [trackIdsDict setValue:trackIdString forKey:trackPersistentIdHex];

      NSMutableDictionary* trackDict = [self serializeTrack:trackItem withId:trackId];

      // add track dictionary object to root tracks dictionary
      [tracksDict setObject:trackDict forKey:[@(trackId) stringValue]];
    }
  }

  return tracksDict;
}

- (NSMutableDictionary*) serializeTrack:(ITLibMediaItem*) trackItem withId: (NSUInteger) trackId {

  NSMutableDictionary* trackDict = [NSMutableDictionary dictionary];

  NSUInteger artworkCount = trackItem.hasArtworkAvailable ? 1 : 0;

  [trackDict setValue:[NSNumber numberWithInteger: trackId] forKey:@"Track ID"];
  [trackDict setValue:trackItem.title forKey:@"Name"];
  [trackDict setValue:trackItem.artist.name forKey:@"Artist"];
  [trackDict setValue:trackItem.album.albumArtist forKey:@"Album Artist"];
  [trackDict setValue:trackItem.album.title forKey:@"Album"];
  [trackDict setValue:trackItem.genre forKey:@"Genre"];
  [trackDict setValue:trackItem.kind forKey:@"Kind"];
  [trackDict setValue:[NSNumber numberWithUnsignedLongLong:trackItem.fileSize] forKey:@"Size"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.totalTime] forKey:@"Total Time"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.album.discNumber] forKey:@"Disc Number"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.album.discCount] forKey:@"Disc Count"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.trackNumber] forKey:@"Track Number"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.album.trackCount] forKey:@"Track Count"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.year] forKey:@"Year"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.beatsPerMinute] forKey:@"BPM"];
  [trackDict setValue:trackItem.modifiedDate forKey:@"Date Modified"];
  [trackDict setValue:trackItem.addedDate forKey:@"Date Added"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.bitrate] forKey:@"Bit Rate"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.sampleRate] forKey:@"Sample Rate"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.sampleRate] forKey:@"Sample Rate"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.playCount] forKey:@"Play Count"];
  //[trackDict setValue:trackItem.lastPlayedDate forKey:@"Play Date"]; convert to epoch
  [trackDict setValue:trackItem.lastPlayedDate forKey:@"Play Date UTC"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.skipCount] forKey:@"Skip Count"];
  [trackDict setValue:trackItem.skipDate forKey:@"Skip Date"];
  [trackDict setValue:trackItem.releaseDate forKey:@"Release Date"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.volumeNormalizationEnergy] forKey:@"Normalization"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:artworkCount] forKey:@"Artwork Count"];
  [trackDict setValue:trackItem.album.sortTitle forKey:@"Sort Album"];
  [trackDict setValue:trackItem.album.sortAlbumArtist forKey:@"Sort Album Artist"];
  [trackDict setValue:trackItem.artist.sortName forKey:@"Sort Artist"];
  [trackDict setValue:trackItem.sortTitle forKey:@"Sort Name"];
  [trackDict setValue:[LibrarySerializer getHexadecimalPersistentId:trackItem.persistentID] forKey:@"Persistent ID"];
//  [trackDict setValue:trackItem.title forKey:@"Track Type"];
  [trackDict setValue:[NSNumber numberWithUnsignedInteger:trackItem.fileType] forKey:@"File Type"];
  [trackDict setValue:[trackItem.location absoluteString] forKey:@"Location"];

  return trackDict;
}

- (void) writeDictionary {

  NSLog(@"[LibrarySerializer writeDictionary]");

  NSError* serializeError = nil;
  NSData* data = [NSPropertyListSerialization dataWithPropertyList:_dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&serializeError];
  if (serializeError) {
      NSLog(@"[LibrarySerializer writeDictionary] error serializing dictionary: %@", serializeError);
      return;
  }

  NSError* writeError = nil;
  BOOL writeSuccessful = [data writeToFile:_filePath
                                   options:NSDataWritingAtomic
                                     error:&writeError];
  if (!writeSuccessful) {
      NSLog (@"[LibrarySerializer writeDictionary] error writing dictionary: %@", writeError);
      return;
  }
}

@end
