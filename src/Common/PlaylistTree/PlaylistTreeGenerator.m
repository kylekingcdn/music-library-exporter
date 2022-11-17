//
//  PlaylistTreeGenerator.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-13.
//

#import "PlaylistTreeGenerator.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "PlaylistFilterGroup.h"
#import "PlaylistTreeNode.h"
#import "Utils.h"

@implementation PlaylistTreeGenerator

- (instancetype)init {

  if (self = [super init]) {

    _filters = nil;
    _flattenFolders = NO;

    _customSortColumns = [NSDictionary dictionary];
    _customSortOrders = [NSDictionary dictionary];

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithFilters:(PlaylistFilterGroup*)filters {

  if (self = [self init]) {

    _filters = filters;
    
    return self;
  }
  else {
    return nil;
  }
}

- (nullable PlaylistTreeNode*)generateTreeWithError:(NSError**)error {

  PlaylistTreeNode* root = [[PlaylistTreeNode alloc] init];

  // init ITLibrary
  ITLibrary* library = [ITLibrary libraryWithAPIVersion:@"1.1" options:ITLibInitOptionNone error:error];

  if (library != nil) {

    NSMutableArray<PlaylistTreeNode*>* topLevelPlaylists = [NSMutableArray array];

    for (ITLibPlaylist* playlist in library.allPlaylists) {

      if ([_filters filtersPassForPlaylist:playlist]) {

        // additional filter to only generate top level playlists when folders are retained
        if (_flattenFolders || playlist.parentID == nil) {

          [topLevelPlaylists addObject:[self createNodeForPlaylist:playlist fromSourcePlaylists:library.allPlaylists]];
        }
      }
    }

    [root setChildren:topLevelPlaylists];
  }

  return root;
}

- (PlaylistTreeNode*)createNodeForPlaylist:(ITLibPlaylist*)playlist fromSourcePlaylists:(NSArray<ITLibPlaylist*>*)sourcePlaylists{

  PlaylistTreeNode* node = [PlaylistTreeNode nodeWithPlaylist:playlist];

  NSString* playlistHexID = [Utils hexStringForPersistentId:playlist.persistentID];

  // set custom sort colummn
  NSString* sortColumnTitle = [_customSortColumns valueForKey:playlistHexID];
  PlaylistSortColumnType sortColumn = [Utils playlistSortColumnForTitle:sortColumnTitle];
  [node setCustomSortColumn:sortColumn];

  // set custom sort order
  NSString* sortOrderTitle = [_customSortOrders valueForKey:playlistHexID];
  PlaylistSortOrderType sortOrder = [Utils playlistSortOrderForTitle:sortOrderTitle];
  [node setCustomSortOrder:sortOrder];

  // generate children if folders are enabled
  if (!_flattenFolders) {
    [node setChildren:[self generateChildrenForPlaylist:playlist fromSourcePlaylists:sourcePlaylists]];
  }

  return node;
}

- (NSArray<PlaylistTreeNode*>*)generateChildrenForPlaylist:(ITLibPlaylist*)playlist fromSourcePlaylists:(NSArray<ITLibPlaylist*>*)sourcePlaylists{

  NSMutableArray<PlaylistTreeNode*>* children = [NSMutableArray array];

  if (playlist.kind == ITLibPlaylistKindFolder) {

    for (ITLibPlaylist* sourcePlaylist in sourcePlaylists) {

      // sourcePlaylist is a child of the provided playlist
      if (sourcePlaylist.parentID != nil && [sourcePlaylist.parentID isEqualToNumber:playlist.persistentID]) {

        // generate child
        [children addObject:[self createNodeForPlaylist:sourcePlaylist fromSourcePlaylists:sourcePlaylists]];
      }
    }
  }

  return children;
}

@end
