//
//  Utils.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-18.
//

#import "Utils.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "Logger.h"


@implementation Utils

+ (nullable NSString*)hexStringForPersistentId:(nullable NSNumber*)persistentId {

  if (persistentId == nil) {
    return nil;
  }
  
  return [NSString stringWithFormat:@"%016llX", persistentId.unsignedLongLongValue];
}

+ (PlaylistSortColumnType)playlistSortColumnForTitle:(nullable NSString*)title {

  if (title == nil) {
    return PlaylistSortColumnNull;
  }

  if ([title isEqualToString:@"Title"]) {
    return PlaylistSortColumnTitle;
  }
  else if ([title isEqualToString:@"Artist"]) {
    return PlaylistSortColumnArtist;
  }
  else if ([title isEqualToString:@"Album Artist"]) {
    return PlaylistSortColumnAlbumArtist;
  }
  else if ([title isEqualToString:@"Date Added"]) {
    return PlaylistSortColumnDateAdded;
  }

  return PlaylistSortColumnNull;
}

+ (PlaylistSortOrderType)playlistSortOrderForTitle:(nullable NSString*)title {

  if (title == nil) {
    return PlaylistSortOrderNull;
  }

  if ([title isEqualToString:@"Ascending"]) {
    return PlaylistSortOrderAscending;
  }
  else if ([title isEqualToString:@"Descending"]) {
    return PlaylistSortOrderDescending;
  }

  return PlaylistSortOrderNull;
}

+ (nullable NSString*)mediaItemPropertyForSortColumn:(PlaylistSortColumnType)sortColumn {

  switch (sortColumn) {
    case PlaylistSortColumnTitle: {
      return ITLibMediaItemPropertyTitle;
    }
    case PlaylistSortColumnArtist: {
      return ITLibMediaItemPropertyArtistName;
    }
    case PlaylistSortColumnAlbumArtist: {
      return ITLibMediaItemPropertyAlbumArtist;
    }
    case PlaylistSortColumnDateAdded: {
      return ITLibMediaItemPropertyAddedDate;
    }
    default: {
      return nil;
    }
  }
}

@end
