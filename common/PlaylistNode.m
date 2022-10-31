//
//  PlaylistNode.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import "PlaylistNode.h"

#import <iTunesLibrary/ITLibPlaylist.h>

#import "Utils.h"


@implementation PlaylistNode


#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  return self;
}

+ (PlaylistNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistNode*>*)childNodes {

  PlaylistNode* node = [[PlaylistNode alloc] init];

  [node setPlaylist:playlist];
  [node setChildren:childNodes];
  if (playlist != nil) {
    node->_playlistHexId = [Utils hexStringForPersistentId:playlist.persistentID];
  }
  else {
    node->_playlistHexId = nil;
  }

  return node;
}


#pragma mark - Accessors

- (BOOL)isLeaf {

  return _playlist && _playlist.kind != ITLibPlaylistKindFolder;
}

- (NSString*)kindDescription {

  if (_playlist.distinguishedKind != ITLibDistinguishedPlaylistKindNone || _playlist.isMaster) {
    return @"Internal";
  }

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
      return [NSString string]; //[NSString stringWithFormat:@"%lu songs", _playlist.items.count];
    }
  }
}


@end
