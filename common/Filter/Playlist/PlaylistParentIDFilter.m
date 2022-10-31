//
//  PlaylistParentIDFilter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistParentIDFilter.h"

#import <iTunesLibrary/ITLibPlaylist.h>

#import "Utils.h"

@implementation PlaylistParentIDFilter {

  NSMutableSet<NSString*>* _excludedIDs;
}

- (instancetype)init {

  self = [super init];

  _excludedIDs = [NSMutableSet set];

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

  NSString* parentPlaylistID = [Utils hexStringForPersistentId:playlist.parentID];
  
  // excluded IDs contains the playlist's parent persistent ID
  if (parentPlaylistID != nil && [_excludedIDs containsObject:parentPlaylistID]) {
    return NO;
  }
  else {
    return YES;
  }
}

@end
