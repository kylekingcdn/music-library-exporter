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
#import "PopupButtonTableCellView.h"


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

+ (TableColumnType)columnWithIdentifier:(NSString*)columnIdentifier {

  if ([columnIdentifier isEqualToString:@"titleColumn"]) {
    return TitleColumn;
  }
  else if ([columnIdentifier isEqualToString:@"kindColumn"]) {
    return KindColumn;
  }
  else if ([columnIdentifier isEqualToString:@"itemsColumn"]) {
    return ItemsColumn;
  }
  else if ([columnIdentifier isEqualToString:@"sortingColumn"]) {
    return SortingColumn;
  }

  return NullColumn;
}

+ (nullable NSString*)cellViewIdentifierForColumn:(TableColumnType)column {

  switch (column) {
    case TitleColumn: {
      return @"titleCellView";
    }
    case KindColumn: {
      return @"kindCellView";
    }
    case ItemsColumn: {
      return @"itemsCellView";
    }
    case SortingColumn: {
      return @"sortingCellView";
    }
    default: {
      return nil;
    }
  }
}

+ (nullable NSString*)cellTitleForColumn:(TableColumnType)column andNode:(PlaylistNode*)node {

  if (!node) {
    return nil;
  }

  switch (column) {
    case TitleColumn: {
      return node.playlist.name;
    }
    case KindColumn: {
      return node.kindDescription;
    }
    case ItemsColumn: {
      return node.itemsDescription;
    }
    case SortingColumn: {
      return @"Default";
    }
    default: {
      return nil;
    }
  }
}

- (nullable PlaylistNode*)playlistNodeForCellView:(NSTableCellView*)cellView {

  if (!cellView) {
    return nil;
  }

  NSInteger row = [_outlineView rowForView:cellView];
  PlaylistNode* node = [_outlineView itemAtRow:row];

  return node;
}

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

- (IBAction)setPlaylistExcludedForCellView:(id)sender {

  PlaylistNode* node = [self playlistNodeForCellView:sender];
  if (!node) {
    return;
  }

  BOOL excluded = ([sender state] == NSControlStateValueOff);
  NSNumber* playlistId = node.playlist.persistentID;

  [_exportConfiguration setExcluded:excluded forPlaylistId:playlistId];
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

  TableColumnType columnType = [PlaylistsViewController columnWithIdentifier:tableColumn.identifier];
  if (columnType == NullColumn) {
    return nil;
  }

  NSString* cellViewId = [PlaylistsViewController cellViewIdentifierForColumn:columnType];
  NSString* cellViewTitle = [PlaylistsViewController cellTitleForColumn:columnType andNode:node];

  // checkbox columns
  if (columnType == TitleColumn) {

    CheckBoxTableCellView* cellView = [outlineView makeViewWithIdentifier:cellViewId owner:nil];

    NSControlStateValue state = [_exportConfiguration isPlaylistIdExcluded:node.playlist.persistentID] ? NSControlStateValueOff : NSControlStateValueOn;

    [cellView.checkbox setAction:@selector(setPlaylistExcludedForCellView:)];
    [cellView.checkbox setTarget:self];
    [cellView.checkbox setState:state];
    [cellView.checkbox setTitle:cellViewTitle];

    return cellView;
  }

  // popup button columns
  else if (columnType == SortingColumn) {

    PopupButtonTableCellView* cellView = [outlineView makeViewWithIdentifier:cellViewId owner:nil];
    // TODO: handle custom sorting


    return cellView;
  }

  // text field columns
  else if (columnType != NullColumn){

    NSTableCellView* cellView = [outlineView makeViewWithIdentifier:cellViewId owner:nil];
    if (!cellView) {
      NSLog(@"PlaylistsViewController [viewForTableColumn:%@] error - failed to make cell view", tableColumn.identifier);
      return nil;
    }

    [cellView.textField setStringValue:cellViewTitle];
    
    return cellView;
  }

  return nil;
}

@end
