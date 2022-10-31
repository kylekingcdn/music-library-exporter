//
//  PlaylistIDFilter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistIDFilter.h"

#import <iTunesLibrary/ITLibPlaylist.h>

#import "Utils.h"

@implementation PlaylistIDFilter {

  NSMutableSet<NSString*>* _excludedIDs;
}

- (instancetype)init {

  self = [super init];

  return self;
}

- (instancetype)initWithExcludedIDs:(NSSet<NSString*>*)excludedIDs {

  if (self = [super init]) {
    _excludedIDs = [excludedIDs mutableCopy];
    return self;
  }
  else {
    return nil;
  }
}

- (void)addExcludedID:(NSNumber*)playlistID {

  [_excludedIDs addObject:[Utils hexStringForPersistentId:playlistID]];
}

- (void)removeExcludedID:(NSNumber*)playlistID {

  [_excludedIDs removeObject:[Utils hexStringForPersistentId:playlistID]];
}

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist {

  // excluded IDs contains the playlist's persistent ID
  if ([_excludedIDs containsObject:[Utils hexStringForPersistentId:playlist.persistentID]]) {
    return NO;
  }
  else {
    return YES;
  }
}

@end
