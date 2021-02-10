//
//  PlaylistsViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import "PlaylistsViewController.h"

#import <iTunesLibrary/ITLibPlaylist.h>
#import <iTunesLibrary/ITLibrary.h>

#import "PlaylistNode.h"
#import "ExportConfiguration.h"
#import "CheckBoxTableCellView.h"


@interface PlaylistsViewController ()

@property (weak) IBOutlet NSOutlineView *outlineView;

@end


@implementation PlaylistsViewController {

  PlaylistNode* _rootNode;
//  NSTreeController* _treeController;
}


#pragma mark - Initializers

- (instancetype)init {

  self = [super initWithNibName:@"PlaylistsView" bundle:nil];

  return self;
}

+ (PlaylistsViewController*)controllerWithLibrary:(ITLibrary*)lib andExportConfig:(ExportConfiguration*)exportConfig {

  PlaylistsViewController* controller = [[PlaylistsViewController alloc] init];

  [controller setLibrary:lib];
  [controller setExportConfiguration:exportConfig];

  return controller;
}


#pragma mark - Accessors

- (NSArray<ITLibPlaylist*>*)playlistsWithParentId:(nullable NSNumber*)parentId {

  NSMutableArray<ITLibPlaylist*>* children = [NSMutableArray array];

  for (ITLibPlaylist* playlist in _library.allPlaylists) {

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

- (NSArray<ITLibPlaylist*>*)childrenForPlaylist:(nullable ITLibPlaylist*)playlist {

  // if playlist is nil, we return the root playlists
  if (playlist && playlist.kind != ITLibPlaylistKindFolder) {
    return [NSArray array];
  }
  else {
    return [self playlistsWithParentId:playlist.persistentID];
  }
}

- (PlaylistNode*)createNodeForPlaylist:(nullable ITLibPlaylist*)playlist {

  NSMutableArray<PlaylistNode*>* childNodes = [NSMutableArray array];

  NSArray<ITLibPlaylist*>* childPlaylists = [self childrenForPlaylist:playlist];

  // recursively generate child nodes for playlist
  for (ITLibPlaylist* childPlaylist in childPlaylists) {
    PlaylistNode* childNode = [self createNodeForPlaylist:childPlaylist];
    [childNodes addObject:childNode];
  }

  return [PlaylistNode nodeWithPlaylist:playlist andChildren:childNodes];
}


#pragma mark - Mutators

- (void)initPlaylistNodes {

  if (!_exportConfiguration || !_library) {
    return;
  }

  _rootNode = [self createNodeForPlaylist:nil];
}


#pragma mark - NSViewController

- (void)viewDidLoad {

  [super viewDidLoad];

  [self initPlaylistNodes];
  [_outlineView reloadData];
}


#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(nullable id)item {

  if(!_rootNode) {
    return 0;
  }

  // use rootNode if item is nil
  PlaylistNode* node = item ? item : _rootNode;

  return node.children.count;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(nullable id)item {

  if(!_rootNode) {
    return nil;
  }

  PlaylistNode* node = item ? item : _rootNode;

  return [node.children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {

  if(!_rootNode) {
    return NO;
  }

  PlaylistNode* node = item ? item : _rootNode;

  return node.children.count > 0;
}


#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item {

  PlaylistNode* node = item;
  if (!node) {
    return nil;
  }


  // checkbox columns
  if ([tableColumn.identifier isEqualToString:@"titleColumn"]) {
    NSString* cellId = @"titleCellView";
    CheckBoxTableCellView* cellView = [outlineView makeViewWithIdentifier:cellId owner:nil];

    NSControlStateValue state;
    if ([_exportConfiguration.excludedPlaylistPersistentIds containsObject:node.playlist.persistentID]) {
      state = NSControlStateValueOff;
    }
    else {
      state = NSControlStateValueOn;
    }

    [cellView.checkbox setState:state];
    [cellView.checkbox setTitle:node.playlist.name];
    return cellView;
  }

  // drop down columns
//  else if ([tableColumn.identifier isEqualToString:@"sortingColumn"]) {
//    NSString* cellId = @"sortingCellView";
//    NSString* cellTitle = @"Default";

//    return nil;
//  }

  // text field columns
  else {

    NSString* cellTitle;
    NSString* cellId;

    if ([tableColumn.identifier isEqualToString:@"kindColumn"]) {
      cellId = @"kindCellView";
      cellTitle = node.kindDescription;
    }
    else if ([tableColumn.identifier isEqualToString:@"itemsColumn"]) {
      cellId = @"itemsCellView";
      cellTitle = node.itemsDescription;
    }
    else if ([tableColumn.identifier isEqualToString:@"sortingColumn"]) {
      cellId = @"sortingCellView";
      cellTitle = @"Default";
    }
    else {
      return nil;
    }

    NSTableCellView* cellView = [outlineView makeViewWithIdentifier:cellId owner:nil];
    if (!cellView) {
      NSLog(@"PlaylistsViewController [viewForTableColumn:%@] error - failed to make cell view", tableColumn.identifier);
      return nil;
    }

    [cellView.textField setStringValue:cellTitle];
    return cellView;
  }
}

@end
