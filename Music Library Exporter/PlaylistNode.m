//
//  PlaylistNode.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import "PlaylistNode.h"

#import <iTunesLibrary/ITLibPlaylist.h>


@implementation PlaylistNode


#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  return self;
}

+ (PlaylistNode*)nodeWithPlaylist:(ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistNode*>*)childNodes {

  PlaylistNode* node = [[PlaylistNode alloc] init];

  [node setPlaylist:playlist];
  [node setChildren:childNodes];

  return node;
}


#pragma mark - Accessors

- (BOOL)isLeaf {

  return _playlist && _playlist.kind != ITLibPlaylistKindFolder;
}

- (NSString*)kindDescription {

  switch (_playlist.kind) {
    case ITLibPlaylistKindRegular: {
      return @"Playlist";
    }
    case ITLibPlaylistKindSmart: {
      return @"Smart Playlist";
    }
    case ITLibPlaylistKindGenius: {
      return @"Genius";
    }
    case ITLibPlaylistKindFolder: {
      return @"Folder";
    }
    case ITLibPlaylistKindGeniusMix: {
      return @"Genius Mix";
    }
  }
}

- (NSString*)itemsDescription {

  switch (_playlist.kind) {
    case ITLibPlaylistKindFolder: {
      return [NSString stringWithFormat:@"%lu playlists", _children.count];
    }
    case ITLibPlaylistKindRegular:
    case ITLibPlaylistKindSmart:
    case ITLibPlaylistKindGenius:
    case ITLibPlaylistKindGeniusMix: {
      return [NSString stringWithFormat:@"%lu songs", _playlist.items.count];
    }
  }
}


@end
