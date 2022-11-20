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

@end
