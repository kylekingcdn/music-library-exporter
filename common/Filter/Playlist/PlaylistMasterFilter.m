//
//  PlaylistMasterFilter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistMasterFilter.h"

#import <iTunesLibrary/ITLibPlaylist.h>

@implementation PlaylistMasterFilter

- (instancetype)init {

  if (self = [super init]) {

    return self;
  }
  else {
    return nil;
  }
}

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist {

  return playlist.master == NO;
}

@end
