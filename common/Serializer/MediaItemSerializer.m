//
//  MediaItemSerializer.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "MediaItemSerializer.h"

#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibAlbum.h>

#import "Logger.h"
#import "MediaEntityRepository.h"
#import "MediaItemFilterGroup.h"
#import "OrderedDictionary.h"
#import "PathMapper.h"
#import "Utils.h"

@implementation MediaItemSerializer {

  MediaEntityRepository* _entityRepository;

  NSDictionary* _mediaItemKindMappings;
}

- (instancetype) initWithEntityRepository:(MediaEntityRepository*)entityRepository {

  self = [super init];

  _entityRepository = entityRepository;

  _mediaItemKindMappings = @{
      //[[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindSong] stringValue]: @"",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindAlertTone] stringValue]: @"Tone",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindAudiobook] stringValue]: @"Audiobook",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindBook] stringValue]: @"Book",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindMovie] stringValue]: @"Movie",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindMusicVideo] stringValue]: @"Music Video",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindPodcast] stringValue]: @"Podcast",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindTVShow] stringValue]: @"TV Show",
      [[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindRingtone] stringValue]: @"Ringtone",
  };

  return self;
}

- (OrderedDictionary*)serializeItems:(NSArray<ITLibMediaItem*>*)items {

  MutableOrderedDictionary* itemsDict = [MutableOrderedDictionary dictionary];

  NSUInteger serializedItems = 0;
  NSUInteger totalItems = items.count;

  for (ITLibMediaItem* item in items) {

    if (_itemFilters == nil || [_itemFilters filtersPassForItem:item]) {

      // add item dict to main items dict with key of item ID
      [itemsDict setObject:[self serializeItem:item] forKey:[[_entityRepository getIDForEntity:item] stringValue]];
    }

    serializedItems++;

    if (_delegate != nil && [_delegate respondsToSelector:@selector(serializedItems:ofTotal:)]) {
      [_delegate serializedItems:serializedItems ofTotal:totalItems];
    }
  }

  return itemsDict;
}

- (OrderedDictionary*)serializeItem:(ITLibMediaItem*)item {

  MutableOrderedDictionary* itemDict = [MutableOrderedDictionary dictionary];

  [itemDict setValue:[_entityRepository getIDForEntity:item] forKey:@"Track ID"];
  [itemDict setValue:item.title forKey:@"Name"];
  if (item.artist.name) {
    [itemDict setValue:item.artist.name forKey:@"Artist"];
  }
  if (item.album.albumArtist) {
    [itemDict setValue:item.album.albumArtist forKey:@"Album Artist"];
  }
  if (item.composer.length > 0) {
    [itemDict setValue:item.composer forKey:@"Composer"];
  }
  if (item.album.title.length > 0) {
    [itemDict setValue:item.album.title forKey:@"Album"];
  }
  if (item.grouping) {
    [itemDict setValue:item.grouping forKey:@"Grouping"];
  }
  if (item.genre.length > 0) {
    [itemDict setValue:item.genre forKey:@"Genre"];
  }
  if (item.kind) {
    [itemDict setValue:item.kind forKey:@"Kind"];
  }
  if (item.comments) {
    [itemDict setValue:item.comments forKey:@"Comments"];
  }
  if (item.fileSize > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedLongLong:item.fileSize] forKey:@"Size"];
  }
  if (item.totalTime > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.totalTime] forKey:@"Total Time"];
  }
  if (item.startTime > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.startTime] forKey:@"Start Time"];
  }
  if (item.stopTime > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.stopTime] forKey:@"Stop Time"];
  }
  if (item.album.discNumber > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.album.discNumber] forKey:@"Disc Number"];
  }
  if (item.album.discCount > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.album.discCount] forKey:@"Disc Count"];
  }
  if (item.trackNumber > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.trackNumber] forKey:@"Track Number"];
  }
  if (item.album.trackCount > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.album.trackCount] forKey:@"Track Count"];
  }
  if (item.year > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.year] forKey:@"Year"];
  }
  if (item.beatsPerMinute > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.beatsPerMinute] forKey:@"BPM"];
  }
  if (item.modifiedDate) {
    [itemDict setValue:item.modifiedDate forKey:@"Date Modified"];
  }
  if (item.addedDate) {
    [itemDict setValue:item.addedDate forKey:@"Date Added"];
  }
  if (item.bitrate > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.bitrate] forKey:@"Bit Rate"];
  }
  if (item.sampleRate > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.sampleRate] forKey:@"Sample Rate"];
  }
  if (item.volumeAdjustment != 0) {
    [itemDict setValue:[NSNumber numberWithInteger:item.volumeAdjustment] forKey:@"Volume Adjustment"];
  }
  if (item.album.gapless) {
    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Part Of Gapless Album"];
  }
  if (item.rating != 0) {
    [itemDict setValue:[NSNumber numberWithInteger:item.rating] forKey:@"Rating"];
  }
  if (item.ratingComputed) {
    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Rating Computed"];
  }
  if (item.album.rating != 0) {
    [itemDict setValue:[NSNumber numberWithInteger:item.album.rating] forKey:@"Album Rating"];
  }
  if (item.album.ratingComputed) {
    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Album Rating Computed"];
  }
  if (item.playCount > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.playCount] forKey:@"Play Count"];
  }
  if (item.lastPlayedDate) {
//    [itemDict setValue:[NSNumber numberWithLongLong:item.lastPlayedDate.timeIntervalSince1970+2082844800] forKey:@"Play Date"]; - invalid
    [itemDict setValue:item.lastPlayedDate forKey:@"Play Date UTC"];
  }
  if (item.skipCount > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.skipCount] forKey:@"Skip Count"];
  }
  if (item.skipDate) {
    [itemDict setValue:item.skipDate forKey:@"Skip Date"];
  }
  if (item.releaseDate) {
    [itemDict setValue:item.releaseDate forKey:@"Release Date"];
  }
  if (item.volumeNormalizationEnergy > 0) {
    [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.volumeNormalizationEnergy] forKey:@"Normalization"];
  }
  if (item.album.compilation) {
    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Compilation"];
  }
//  if (item.hasArtworkAvailable) {
//    [itemDict setValue:[NSNumber numberWithUnsignedInteger:1] forKey:@"Artwork Count"]; - unavailable
//  }
  if (item.album.sortTitle) {
    [itemDict setValue:item.album.sortTitle forKey:@"Sort Album"];
  }
  if (item.album.sortAlbumArtist) {
    [itemDict setValue:item.album.sortAlbumArtist forKey:@"Sort Album Artist"];
  }
  if (item.artist.sortName) {
    [itemDict setValue:item.artist.sortName forKey:@"Sort Artist"];
  }
  if (item.sortComposer) {
    [itemDict setValue:item.sortComposer forKey:@"Sort Composer"];
  }
  if (item.sortTitle) {
    [itemDict setValue:item.sortTitle forKey:@"Sort Name"];
  }
  if (item.isUserDisabled) {
    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Disabled"];
  }

  [itemDict setValue:[Utils hexStringForPersistentId:item.persistentID] forKey:@"Persistent ID"];

  // add boolean attributes for media kind
  NSString* mediaItemKindStr = [[NSNumber numberWithUnsignedInteger:item.mediaKind] stringValue];
  if ([_mediaItemKindMappings doesContain:mediaItemKindStr]) {
    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:[_mediaItemKindMappings valueForKey:mediaItemKindStr]];
  }
//  [itemDict setValue:item.title forKey:@"Track Type"]; - invalid

//  [itemDict setValue:[NSNumber numberWithUnsignedInteger:item.fileType] forKey:@"File Type"]; - deprecated
//  if (item.cloud) {
//    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Matched"]; - unavailable
//  }
//  if (item.purchased) {
//    [itemDict setValue:[NSNumber numberWithBool:YES] forKey:@"Purchased"]; - invalid
//  }

  if (item.location) {
    [itemDict setValue:[[NSURL fileURLWithPath:[_pathMapper mapPath:item.location.path]] absoluteString] forKey:@"Location"];
  }

  return itemDict;
}

@end
