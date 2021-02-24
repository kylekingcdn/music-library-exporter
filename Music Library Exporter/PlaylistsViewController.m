//
//  PlaylistsViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import "PlaylistsViewController.h"

#import <iTunesLibrary/ITLibPlaylist.h>
#import <iTunesLibrary/ITLibrary.h>

#import "Logger.h"
#import "Utils.h"
#import "PlaylistNode.h"
#import "PlaylistTree.h"
#import "ExportConfiguration.h"
#import "LibraryFilter.h"
#import "CheckBoxTableCellView.h"
#import "PopupButtonTableCellView.h"


@interface PlaylistsViewController ()

@property (weak) IBOutlet NSOutlineView *outlineView;

@end


@implementation PlaylistsViewController {

  NSUserDefaults* _groupDefaults;

  ITLibrary* _library;

  LibraryFilter* _libraryFilter;
  PlaylistTree* _playlistTree;
}


#pragma mark - Initializers

- (instancetype)initWithLibrary:(ITLibrary*)library {

  self = [super initWithNibName:@"PlaylistsView" bundle:nil];

  _library = library;
  _libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];

  _playlistTree = [[PlaylistTree alloc] init];

  // show playlists that have been manually excluded to allow for changing status
  [_libraryFilter setFilterExcludedPlaylistIds:NO];

  // detect changes in NSUSerDefaults for app group
  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults addObserver:self forKeyPath:@"FlattenPlaylistHierarchy" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"IncludeInternalPlaylists" options:NSKeyValueObservingOptionNew context:NULL];

  return self;
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

  if (node == nil) {
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
    default: {
      return nil;
    }
  }
}

+ (PlaylistSortColumnType)playlistSortColumnForMenuItemTag:(NSInteger)tag {

  if (tag > 200 && tag < 300) {

    switch (tag) {
      case 201: {
        return PlaylistSortColumnTitle;
      }
      case 202: {
        return PlaylistSortColumnArtist;
      }
      case 203: {
        return PlaylistSortColumnAlbumArtist;
      }
      case 204: {
        return PlaylistSortColumnDateAdded;
      }
      default: {
        break;
      }
    }
  }

  return PlaylistSortColumnNull;
}

+ (PlaylistSortOrderType)playlistSortOrderForMenuItemTag:(NSInteger)tag {

  if (tag > 300 && tag < 400) {

    switch (tag) {
      case 301: {
        return PlaylistSortOrderAscending;
      }
      case 302: {
        return PlaylistSortOrderDescending;
      }
      default: {
        break;
      }
    }
  }

  return PlaylistSortOrderNull;
}

+ (NSInteger)menuItemTagForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn {

  switch (sortColumn) {
    case PlaylistSortColumnTitle: {
      return 201;
    }
    case PlaylistSortColumnArtist: {
      return 202;
    }
    case PlaylistSortColumnAlbumArtist: {
      return 203;
    }
    case PlaylistSortColumnDateAdded: {
      return 204;
    }
    default: {
      return -1;
    }
  }
}

+ (NSInteger)menuItemTagForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder {

  switch (sortOrder) {
    case PlaylistSortOrderAscending: {
      return 301;
    }
    case PlaylistSortOrderDescending: {
      return 302;
    }
    default: {
      return -1;
    }
  }
}

- (BOOL)isNodeExcluded:(nullable PlaylistNode*)node {

  if (node == nil || node.playlistHexId == nil) {
    return NO;
  }

  if ([ExportConfiguration.sharedConfig isPlaylistIdExcluded:node.playlistHexId]) {
    return YES;
  }

  if (!ExportConfiguration.sharedConfig.flattenPlaylistHierarchy && node.playlist.parentID != nil) {
    PlaylistNode* parentNode = [self.outlineView parentForItem:node];
    if (parentNode != nil) {
      return [self isNodeExcluded:parentNode];
    }
  }

  return NO;
}

- (nullable PlaylistNode*)playlistNodeForCellView:(NSView*)cellView {

  NSInteger row = [_outlineView rowForView:cellView];
  if (row == -1) {
    return nil;
  }

  PlaylistNode* node = [_outlineView itemAtRow:row];

  return node;
}

- (void)updateSortingButton:(NSPopUpButton*)button forNode:(PlaylistNode*)node {

  if (node == nil) {
    return;
  }

  PlaylistSortColumnType sortColumn = [ExportConfiguration.sharedConfig playlistCustomSortColumn:node.playlistHexId];
  PlaylistSortOrderType sortOrder = [ExportConfiguration.sharedConfig playlistCustomSortOrder:node.playlistHexId];

  BOOL isDefault = (sortColumn == PlaylistSortColumnNull);

  // fallback to ascending if sort order hasn't been set yet
  if (!isDefault && sortOrder == PlaylistSortOrderNull) {
    sortOrder = PlaylistSortOrderAscending;
  }

  NSInteger sortColumnTag = [PlaylistsViewController menuItemTagForPlaylistSortColumn:sortColumn];
  NSInteger sortOrderTag = [PlaylistsViewController menuItemTagForPlaylistSortOrder:sortOrder];

  for (NSMenuItem* item in button.itemArray) {
    NSInteger itemTag = item.tag;
    if (itemTag == 101) {
      [item setState:(isDefault ? NSControlStateValueOn : NSControlStateValueOff)];
    }
    else if (itemTag > 200 && itemTag < 300) {
      [item setState:(item.tag == sortColumnTag ? NSControlStateValueOn : NSControlStateValueOff)];
    }
    else if (itemTag > 300 && itemTag < 400) {

      [item setEnabled:!isDefault];
      [item setState:(item.tag == sortOrderTag ? NSControlStateValueOn : NSControlStateValueOff)];
    }
  }

  if (isDefault) {
    [button setTitle:@"Default"];
  }
  else {
    [button setTitle:[Utils titleForPlaylistSortColumn:sortColumn]];
  }
}


#pragma mark - Mutators

- (void)initPlaylistNodes {

  if (_library == nil) {
    return;
  }

  [_playlistTree setFlattened:ExportConfiguration.sharedConfig.flattenPlaylistHierarchy];
  [_playlistTree generateForSourcePlaylists:[_libraryFilter getIncludedPlaylists]];
}

- (IBAction)setPlaylistExcludedForCellView:(id)sender {

  PlaylistNode* node = [self playlistNodeForCellView:sender];
  if (node == nil) {
    return;
  }

  BOOL excluded = ([sender state] == NSControlStateValueOff);

  [ExportConfiguration.sharedConfig setExcluded:excluded forPlaylistId:node.playlistHexId];

  [_outlineView reloadItem:node reloadChildren:YES];
}

- (IBAction)setPlaylistSorting:(id)sender {

  PlaylistNode* node = [self playlistNodeForCellView:sender];
  if (node == nil) {
    MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] error - failed to fetch playlist node");
    return;
  }

  NSPopUpButton* popupButton = sender;
  NSMenuItem* triggeredItem = popupButton.selectedItem;
  NSInteger itemTag = triggeredItem.tag;

  // default
  if (itemTag == 101) {
    MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] Default");
    [ExportConfiguration.sharedConfig setDefaultSortingForPlaylist:node.playlistHexId];
  }
  // sort column
  else if (itemTag > 200 && itemTag < 300) {
    PlaylistSortColumnType sortColumn = [PlaylistsViewController playlistSortColumnForMenuItemTag:itemTag];
    if (sortColumn == PlaylistSortColumnNull) {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] error - failed to determine sort column for itemTag:%li", (long)itemTag);
    }
    // ignore if no change
    else if (sortColumn == [ExportConfiguration.sharedConfig playlistCustomSortColumn:node.playlistHexId]) {
      return;
    }
    else {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] column: %@", [Utils titleForPlaylistSortColumn:sortColumn]);
      [ExportConfiguration.sharedConfig setCustomSortColumn:sortColumn forPlaylist:node.playlistHexId];
    }
  }
  // sort order
  else if (itemTag > 300 && itemTag < 400) {
    PlaylistSortOrderType sortOrder = [PlaylistsViewController playlistSortOrderForMenuItemTag:itemTag];
    if (sortOrder == PlaylistSortOrderNull) {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] error - failed to determine sort order for itemTag:%li", (long)itemTag);
    }
    // ignore if no change
    else if (sortOrder == [ExportConfiguration.sharedConfig playlistCustomSortOrder:node.playlistHexId]) {
      return;
    }
    else {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] order: %@", [Utils titleForPlaylistSortOrder:sortOrder]);
      [ExportConfiguration.sharedConfig setCustomSortOrder:sortOrder forPlaylist:node.playlistHexId];
    }
  }

  [self updateSortingButton:popupButton forNode:node];
}


#pragma mark - NSViewController

- (void)viewDidLoad {

  [super viewDidLoad];

  [self initPlaylistNodes];
  [_outlineView reloadData];
}


#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(nullable id)item {

  if(!_playlistTree.rootNode) {
    return 0;
  }

  // use rootNode if item is nil
  PlaylistNode* node = item ? item : _playlistTree.rootNode;

  return node.children.count;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(nullable id)item {

  PlaylistNode* node = item ? item : _playlistTree.rootNode;

  return [node.children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {

  if (_playlistTree.rootNode == nil) {
    return NO;
  }

  PlaylistNode* node = item ? item : _playlistTree.rootNode;

  return node.children.count > 0;
}


#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item {

  PlaylistNode* node = item;
  if (node == nil) {
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

    NSControlStateValue state = [self isNodeExcluded:node] ? NSControlStateValueOff : NSControlStateValueOn;

    [cellView.checkbox setAction:@selector(setPlaylistExcludedForCellView:)];
    [cellView.checkbox setTarget:self];
    [cellView.checkbox setState:state];
    [cellView.checkbox setTitle:cellViewTitle];

    return cellView;
  }

  // popup button columns
  else if (columnType == SortingColumn) {

    PopupButtonTableCellView* cellView = [outlineView makeViewWithIdentifier:cellViewId owner:nil];

    [cellView.button setAction:@selector(setPlaylistSorting:)];
    [cellView.button setTarget:self];

    [self updateSortingButton:cellView.button forNode:node];

    return cellView;
  }

  // text field columns
  else if (columnType != NullColumn){

    NSTableCellView* cellView = [outlineView makeViewWithIdentifier:cellViewId owner:nil];
    if (cellView == nil) {
      MLE_Log_Info(@"PlaylistsViewController [viewForTableColumn:%@] error - failed to make cell view", tableColumn.identifier);
      return nil;
    }

    [cellView.textField setStringValue:cellViewTitle];
    
    return cellView;
  }

  return nil;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"PlaylistsViewController [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:@"FlattenPlaylistHierarchy"] ||
      [aKeyPath isEqualToString:@"IncludeInternalPlaylists"]) {

    [self initPlaylistNodes];
    [_outlineView reloadData];
  }
}


@end
