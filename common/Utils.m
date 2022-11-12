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

+ (NSString*)descriptionForExportState:(ExportState)state {

  switch (state) {

    case ExportStopped: {
        return @"Stopped";
    }
    case ExportPreparing: {
        return @"Preparing";
    }
    case ExportGeneratingTracks: {
        return @"Generating tracks";
    }
    case ExportGeneratingPlaylists: {
        return @"Generating playlists";
    }
    case ExportGeneratingLibrary: {
        return @"Generating library";
    }
    case ExportWritingToDisk: {
        return @"Saving to disk";
    }
    case ExportFinished: {
        return @"Finished";
    }
    case ExportError: {
        return @"Error";
    }
  }
}

+ (NSString*)descriptionForExportDeferralReason:(ExportDeferralReason)reason {

  switch (reason) {
    case ExportDeferralOnBatteryReason: {
      return @"Running on battery";
    }
    case ExportDeferralMainAppOpenReason: {
      return @"Main app open";
    }
    case ExportDeferralErrorReason: {
      return @"Error";
    }
    case ExportDeferralUnknownReason: {
      return @"Unknown";
    }
    case ExportNoDeferralReason: {
      return @"Not deferred";
    }
  }
}

+ (nullable NSString*)titleForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn {

  switch (sortColumn) {
    case PlaylistSortColumnTitle: {
      return @"Title";
    }
    case PlaylistSortColumnArtist: {
      return @"Artist";
    }
    case PlaylistSortColumnAlbumArtist: {
      return @"Album Artist";
    }
    case PlaylistSortColumnDateAdded: {
      return @"Date Added";
    }
    case PlaylistSortColumnNull: {
      return nil;
    }
  }
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

+ (nullable NSString*)titleForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder {

  switch (sortOrder) {
    case PlaylistSortOrderAscending: {
      return @"Ascending";
    }
    case PlaylistSortOrderDescending: {
      return @"Descending";
    }
    case PlaylistSortOrderNull: {
      return nil;
    }
  }
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
