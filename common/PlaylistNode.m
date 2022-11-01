//
//  PlaylistNode.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import "PlaylistNode.h"

#import "Utils.h"


@implementation PlaylistNode

#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  _children = [NSArray array];

  _playlistPersistentHexID = nil;
  _playlistParentPersistentHexID = nil;
  _playlistName = nil;
  _playlistDistinguishedKind = ITLibDistinguishedPlaylistKindNone;
  _playlistKind = ITLibPlaylistKindRegular;
  _playlistMaster = NO;
  
  return self;
}

+ (PlaylistNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistNode*>*)childNodes {

  PlaylistNode* node = [[PlaylistNode alloc] init];

  [node setChildren:childNodes];

  if (playlist != nil) {
    node->_playlistPersistentHexID = [Utils hexStringForPersistentId:playlist.persistentID];
    node->_playlistParentPersistentHexID = [Utils hexStringForPersistentId:playlist.parentID];
    node->_playlistName = playlist.name;
    node->_playlistDistinguishedKind = playlist.distinguishedKind;
    node->_playlistKind = playlist.kind;
    node->_playlistMaster = playlist.isMaster;
  }
  else {
    node->_playlistPersistentHexID = nil;
  }

  return node;
}


#pragma mark - Accessors

- (NSString*)kindDescription {

  if (_playlistDistinguishedKind != ITLibDistinguishedPlaylistKindNone || _playlistMaster) {
    return @"Internal";
  }

  switch (_playlistKind) {
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

  switch (_playlistKind) {
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
