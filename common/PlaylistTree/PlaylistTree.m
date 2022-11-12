//
//  PlaylistTree.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-19.
//

#import "PlaylistTree.h"

#import <iTunesLibrary/ITLibPlaylist.h>

#import "PlaylistTreeNode.h"

@interface PlaylistTree ()

#pragma mark - Private Accessors

- (NSArray<ITLibPlaylist*>*)playlistsWithParentId:(nullable NSNumber*)playlistId;
- (NSArray<ITLibPlaylist*>*)topLevelPlaylists;
- (NSArray<ITLibPlaylist*>*)childrenForPlaylist:(ITLibPlaylist*)playlist;

#pragma mark - Private Mutators

- (PlaylistTreeNode*)createRootNode;
- (PlaylistTreeNode*)createNodeForPlaylist:(ITLibPlaylist*)playlist;

@end


@implementation PlaylistTree {

  NSArray<ITLibPlaylist*>* _filteredPlaylists;
}



#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  [self setFlattened:NO];

  return self;
}


#pragma mark - Accessors

- (NSArray<ITLibPlaylist*>*)playlistsWithParentId:(nullable NSNumber*)parentId {

  NSMutableArray<ITLibPlaylist*>* children = [NSMutableArray array];

  for (ITLibPlaylist* playlist in _filteredPlaylists) {

    // check if we are not looking for root objects (parameterized parentId != nil) and playlist has a valid parent Id
    if (parentId && playlist.parentID) {
      if ([parentId isEqualToNumber:playlist.parentID]) {
        [children addObject:playlist];
      }
    }
    // The result of the above if-statement failing is that one of the IDs is nil.
    //   Therefore both must be nil if their pointer values are equal.
    else if (parentId == playlist.parentID) {
      [children addObject:playlist];
    }
  }

  return children;
}

- (NSArray<ITLibPlaylist*>*)topLevelPlaylists {

  if (_flattened) {
    return _filteredPlaylists;
  }
  else {
    return [self playlistsWithParentId:nil];
  }
}

- (NSArray<ITLibPlaylist*>*)childrenForPlaylist:(ITLibPlaylist*)playlist {

  if (playlist.kind == ITLibPlaylistKindFolder) {
    return [self playlistsWithParentId:playlist.persistentID];
  }
  else {
    return [NSArray array];
  }
}


#pragma mark - Mutators

- (void)generateForSourcePlaylists:(NSArray<ITLibPlaylist*>*)sourcePlaylists {

  _filteredPlaylists = sourcePlaylists;

  // do generation
  _rootNode = [self createRootNode];

  // clear filtered playlists
  _filteredPlaylists = [NSArray array];
}

- (PlaylistTreeNode*)createRootNode {

  NSMutableArray<PlaylistTreeNode*>* childNodes = [NSMutableArray array];

  // folders/hierarchy is disabled - all playlists are children of root and none have their own children
  if (_flattened) {

    for (ITLibPlaylist* childPlaylist in _filteredPlaylists) {
      PlaylistTreeNode* childNode = [PlaylistTreeNode nodeWithPlaylist:childPlaylist andChildren:[NSArray array]];
      [childNodes addObject:childNode];
    }
  }

  else {

    NSArray<ITLibPlaylist*>* childPlaylists = [self topLevelPlaylists];

    // recursively generate child nodes for playlist
    for (ITLibPlaylist* childPlaylist in childPlaylists) {
      PlaylistTreeNode* childNode = [self createNodeForPlaylist:childPlaylist];
      [childNodes addObject:childNode];
    }
  }

  return [PlaylistTreeNode nodeWithPlaylist:nil andChildren:childNodes];
}

- (PlaylistTreeNode*)createNodeForPlaylist:(ITLibPlaylist*)playlist {

  NSMutableArray<PlaylistTreeNode*>* childNodes = [NSMutableArray array];

  NSArray<ITLibPlaylist*>* childPlaylists = [self childrenForPlaylist:playlist];

  // recursively generate child nodes for playlist
  for (ITLibPlaylist* childPlaylist in childPlaylists) {
    PlaylistTreeNode* childNode = [self createNodeForPlaylist:childPlaylist];
    [childNodes addObject:childNode];
  }

  return [PlaylistTreeNode nodeWithPlaylist:playlist andChildren:childNodes];
}

@end
