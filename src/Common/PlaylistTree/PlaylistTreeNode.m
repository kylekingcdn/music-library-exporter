//
//  PlaylistTreeNode.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import "PlaylistTreeNode.h"

#import "Utils.h"


@implementation PlaylistTreeNode

#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _children = [NSArray array];

    _customSortProperty = nil;
    _customSortOrder = PlaylistSortOrderNull;

    _persistentHexID = nil;
    _parentPersistentHexID = nil;
    _name = nil;
    _distinguishedKind = ITLibDistinguishedPlaylistKindNone;
    _kind = ITLibPlaylistKindRegular;
    _master = NO;

    return self;
  }
  else {
    return nil;
  }
}

+ (PlaylistTreeNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist {

  PlaylistTreeNode* node = [[PlaylistTreeNode alloc] init];
  if (playlist != nil) {
    node->_persistentHexID = [Utils hexStringForPersistentId:playlist.persistentID];
    node->_parentPersistentHexID = [Utils hexStringForPersistentId:playlist.parentID];
    node->_name = playlist.name;
    node->_distinguishedKind = playlist.distinguishedKind;
    node->_kind = playlist.kind;
    node->_master = playlist.isMaster;
  }
  else {
    node->_persistentHexID = nil;
  }

  return node;
}

+ (PlaylistTreeNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistTreeNode*>*)childNodes {

  PlaylistTreeNode* node = [PlaylistTreeNode nodeWithPlaylist:playlist];
  [node setChildren:childNodes];

  return node;
}


#pragma mark - Accessors

- (NSString*)kindDescription {

  if (_distinguishedKind != ITLibDistinguishedPlaylistKindNone || _master) {
    return @"Internal";
  }

  switch (_kind) {
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

  switch (_kind) {
    case ITLibPlaylistKindFolder: {
      return [NSString stringWithFormat:@"%lu playlists", _children.count];
    }
    case ITLibPlaylistKindRegular:
    case ITLibPlaylistKindSmart:
    case ITLibPlaylistKindGenius:
    case ITLibPlaylistKindGeniusMix: {
      return [NSString string]; //[NSString stringWithFormat:@"%lu songs", _.items.count];
    }
  }
}


@end
