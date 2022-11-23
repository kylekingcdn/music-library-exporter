//
//  PlaylistsViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import "PlaylistsViewController.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "Logger.h"
#import "PlaylistTreeNode.h"
#import "PlaylistTreeGenerator.h"
#import "ExportConfiguration.h"
#import "CheckBoxTableCellView.h"
#import "PopupButtonTableCellView.h"
#import "PlaylistFilterGroup.h"
#import "SorterDefines.h"

@interface PlaylistsViewController ()

@property (weak) IBOutlet NSOutlineView *outlineView;

@end


@implementation PlaylistsViewController {

  NSUserDefaults* _groupDefaults;

  ExportConfiguration* _exportConfiguration;

  PlaylistTreeNode* _playlistTreeRoot;
}

#pragma mark - Initializers

- (instancetype)init {

  if (self = [super initWithNibName:@"PlaylistsView" bundle:nil]) {

    // detect changes in NSUSerDefaults for app group
    _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
    [_groupDefaults addObserver:self forKeyPath:ExportConfigurationKeyFlattenPlaylistHierarchy options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ExportConfigurationKeyIncludeInternalPlaylists options:NSKeyValueObservingOptionNew context:NULL];

    _exportConfiguration = nil;

    _playlistTreeRoot = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithExportConfiguration:(ExportConfiguration*)exportConfiguration {

  if (self = [self init]) {

    _exportConfiguration = exportConfiguration;

    return self;
  }
  else {
    return nil;
  }
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

+ (nullable NSString*)cellTitleForColumn:(TableColumnType)column andNode:(PlaylistTreeNode*)node {

  if (node == nil) {
    return nil;
  }

  switch (column) {
    case TitleColumn: {
      return node.name;
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

+ (nullable NSString*)playlistSortPropertyForMenuItemTag:(NSInteger)tag {

  if (tag > 200 && tag < 300) {

    switch (tag) {
      case 201: {
        return ITLibMediaItemPropertyAlbumTitle;
      }
      case 202: {
        return ITLibMediaItemPropertyAlbumArtist;
      }
      case 203: {
        return ITLibMediaItemPropertyAlbumRating;
      }
      case 204: {
        return ITLibMediaItemPropertyArtistName;
      }
      case 205: {
        return ITLibMediaItemPropertyBeatsPerMinute;
      }
      case 206: {
        return ITLibMediaItemPropertyBitRate;
      }
      case 207: {
        return ITLibMediaItemPropertyCategory;
      }
      case 208: {
        return ITLibMediaItemPropertyComments;
      }
      case 209: {
        return ITLibMediaItemPropertyComposer;
      }
      case 210: {
        return ITLibMediaItemPropertyAddedDate;
      }
      case 211: {
        return ITLibMediaItemPropertyModifiedDate;
      }
      case 212: {
        return ITLibMediaItemPropertyDescription;
      }
      case 213: {
        return ITLibMediaItemPropertyAlbumDiscNumber;
      }
      case 214: {
        return ITLibMediaItemPropertyGenre;
      }
      case 215: {
        return ITLibMediaItemPropertyGrouping;
      }
      case 216: {
        return ITLibMediaItemPropertyKind;
      }
      case 217: {
        return ITLibMediaItemPropertyLastPlayDate;
      }
      case 218: {
        return ITLibMediaItemPropertySkipDate;
      }
      case 219: {
        return ITLibMediaItemPropertyMovementName;
      }
      case 220: {
        return ITLibMediaItemPropertyMovementNumber;
      }
      case 221: {
        return ITLibMediaItemPropertyPlayCount;
      }
      case 222: {
        return ITLibMediaItemPropertyRating;
      }
      case 223: {
        return ITLibMediaItemPropertyReleaseDate;
      }
      case 224: {
        return ITLibMediaItemPropertySampleRate;
      }
      case 225: {
        return ITLibMediaItemPropertySize;
      }
      case 226: {
        return ITLibMediaItemPropertyUserSkipCount;
      }
      case 227: {
        return ITLibMediaItemPropertyTotalTime;
      }
      case 228: {
        return ITLibMediaItemPropertyTitle;
      }
      case 229: {
        return ITLibMediaItemPropertyTrackNumber;
      }
      case 230: {
        return ITLibMediaItemPropertyWork;
      }
      case 231: {
        return ITLibMediaItemPropertyYear;
      }
      default: {
        return nil;
      }
    }
  }

  return nil;
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

+ (NSInteger)menuItemTagForPlaylistSortProperty:(nullable NSString*)sortProperty {

  if (sortProperty == nil) {
    return -1;
  }

  if ([sortProperty isEqualToString:ITLibMediaItemPropertyAlbumTitle]) {
    return 201;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyAlbumArtist]) {
    return 202;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyAlbumRating]) {
    return 203;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyArtistName]) {
    return 204;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyBeatsPerMinute]) {
    return 205;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyBitRate]) {
    return 206;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyCategory]) {
    return 207;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyComments]) {
    return 208;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyComposer]) {
    return 209;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyAddedDate]) {
    return 210;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyModifiedDate]) {
    return 211;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyDescription]) {
    return 212;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyAlbumDiscNumber]) {
    return 213;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyGenre]) {
    return 214;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyGrouping]) {
    return 215;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyKind]) {
    return 216;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyLastPlayDate]) {
    return 217;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertySkipDate]) {
    return 218;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyMovementName]) {
    return 219;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyMovementNumber]) {
    return 220;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyPlayCount]) {
    return 221;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyRating]) {
    return 222;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyReleaseDate]) {
    return 223;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertySampleRate]) {
    return 224;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertySize]) {
    return 225;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyUserSkipCount]) {
    return 226;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyTotalTime]) {
    return 227;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyTitle]) {
    return 228;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyTrackNumber]) {
    return 229;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyWork]) {
    return 230;
  }
  else if ([sortProperty isEqualToString:ITLibMediaItemPropertyYear]) {
    return 231;
  }

  return -1;
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

- (BOOL)isNodeExcluded:(nullable PlaylistTreeNode*)node {

  if (node == nil || node.persistentHexID == nil) {
    return NO;
  }

  if ([_exportConfiguration isPlaylistIdExcluded:node.persistentHexID]) {
    return YES;
  }

  if (!_exportConfiguration.flattenPlaylistHierarchy) {
    return [self isNodeParentExcluded:node];
  }

  return NO;
}

- (BOOL)isNodeParentExcluded:(nullable PlaylistTreeNode*)node {

  if (node == nil || node.parentPersistentHexID == nil) {
    return NO;
  }

  PlaylistTreeNode* parentNode = [self.outlineView parentForItem:node];

  return parentNode != nil && [self isNodeExcluded:parentNode];
}

- (nullable PlaylistTreeNode*)playlistNodeForCellView:(NSView*)cellView {

  NSInteger row = [_outlineView rowForView:cellView];
  if (row == -1) {
    return nil;
  }

  PlaylistTreeNode* node = [_outlineView itemAtRow:row];

  return node;
}

- (void)updateSortingButton:(NSPopUpButton*)button forNode:(PlaylistTreeNode*)node {

  if (node == nil) {
    return;
  }

  NSString* sortProperty = node.customSortProperty;
  PlaylistSortOrderType sortOrder = node.customSortOrder;

  BOOL isDefault = (sortProperty == nil);

  // fallback to ascending if sort order hasn't been set yet
  if (!isDefault && sortOrder == PlaylistSortOrderNull) {
    sortOrder = PlaylistSortOrderAscending;
  }

  NSInteger sortPropertyTag = [PlaylistsViewController menuItemTagForPlaylistSortProperty:sortProperty];
  NSInteger sortOrderTag = [PlaylistsViewController menuItemTagForPlaylistSortOrder:sortOrder];

  for (NSMenuItem* item in button.itemArray) {
    NSInteger itemTag = item.tag;
    if (itemTag == 101) {
      [item setState:(isDefault ? NSControlStateValueOn : NSControlStateValueOff)];
    }
    else if (itemTag > 200 && itemTag < 300) {
      [item setState:(item.tag == sortPropertyTag ? NSControlStateValueOn : NSControlStateValueOff)];
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
    [button setTitle:[SorterDefines nameForProperty:sortProperty]];
  }
}

#pragma mark - Mutators

- (void)initPlaylistNodes {

  // init playlist filters
  PlaylistFilterGroup* playlistFilters = [[PlaylistFilterGroup alloc] initWithBaseFiltersAndIncludeInternal:_exportConfiguration.includeInternalPlaylists
                                                                                        andFlattenPlaylists:_exportConfiguration.flattenPlaylistHierarchy];

  PlaylistTreeGenerator* generator = [[PlaylistTreeGenerator alloc] initWithFilters:playlistFilters];
  [generator setFlattenFolders:_exportConfiguration.flattenPlaylistHierarchy];
  [generator setCustomSortProperties:_exportConfiguration.playlistCustomSortPropertyDict];
  [generator setCustomSortOrders:_exportConfiguration.playlistCustomSortOrderDict];

  NSError* generateError;
  _playlistTreeRoot = [generator generateTreeWithError:&generateError];
  if (generateError != nil) {
    MLE_Log_Info(@"PlaylistsViewController [initPlaylistNodes] error - failed to generate playlist tree: %@", generateError.localizedDescription);
  }
}

- (IBAction)setPlaylistExcludedForCellView:(id)sender {

  PlaylistTreeNode* node = [self playlistNodeForCellView:sender];
  if (node == nil) {
    return;
  }

  BOOL excluded = ([sender state] == NSControlStateValueOff);

  [_exportConfiguration setExcluded:excluded forPlaylistId:node.persistentHexID];

  [_outlineView reloadItem:node reloadChildren:YES];
}

- (IBAction)setPlaylistSorting:(id)sender {

  PlaylistTreeNode* node = [self playlistNodeForCellView:sender];
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
    [node setCustomSortProperty:nil];
    [_exportConfiguration setDefaultSortingForPlaylist:node.persistentHexID];
  }
  // sort property
  else if (itemTag > 200 && itemTag < 300) {
    NSString* sortProperty = [PlaylistsViewController playlistSortPropertyForMenuItemTag:itemTag];
    if (sortProperty == nil) {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] error - failed to determine sort property for itemTag:%li", (long)itemTag);
    }
    // ignore if no change
    else if ([sortProperty isEqualToString:node.customSortProperty]) {
      return;
    }
    else {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] property: %@", sortProperty);
      [node setCustomSortProperty:sortProperty];
      [_exportConfiguration setCustomSortProperty:sortProperty forPlaylist:node.persistentHexID];
    }
  }
  // sort order
  else if (itemTag > 300 && itemTag < 400) {
    PlaylistSortOrderType sortOrder = [PlaylistsViewController playlistSortOrderForMenuItemTag:itemTag];
    if (sortOrder == PlaylistSortOrderNull) {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] error - failed to determine sort order for itemTag:%li", (long)itemTag);
    }
    // ignore if no change
    else if (sortOrder == node.customSortOrder) {
      return;
    }
    else {
      MLE_Log_Info(@"PlaylistsViewController [setPlaylistSorting] order: %@", PlaylistSortOrderNames[sortOrder]);
      [node setCustomSortOrder:sortOrder];
      [_exportConfiguration setCustomSortOrder:sortOrder forPlaylist:node.persistentHexID];
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

#pragma mark - NSObject

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {

  MLE_Log_Info(@"PlaylistsViewController [observeValueForKeyPath:%@]", aKeyPath);

  if ([aKeyPath isEqualToString:ExportConfigurationKeyFlattenPlaylistHierarchy] ||
      [aKeyPath isEqualToString:ExportConfigurationKeyIncludeInternalPlaylists]) {

    [self initPlaylistNodes];
    [_outlineView reloadData];
  }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(nullable id)item {

  if(_playlistTreeRoot == nil) {
    return 0;
  }

  // use rootNode if item is nil
  PlaylistTreeNode* node = item ? item : _playlistTreeRoot;

  return node.children.count;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(nullable id)item {

  PlaylistTreeNode* node = item ? item : _playlistTreeRoot;

  return [node.children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {

  if (_playlistTreeRoot == nil) {
    return NO;
  }

  PlaylistTreeNode* node = item ? item : _playlistTreeRoot;

  return node.children.count > 0;
}

#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView*)outlineView viewForTableColumn:(NSTableColumn*)tableColumn item:(id)item {

  PlaylistTreeNode* node = item;
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
    BOOL checkBoxEnabled = YES;
    if (!_exportConfiguration.flattenPlaylistHierarchy && [self isNodeParentExcluded:node]) {
      checkBoxEnabled = NO;
    }
    [cellView.checkbox setAction:@selector(setPlaylistExcludedForCellView:)];
    [cellView.checkbox setTarget:self];
    [cellView.checkbox setState:state];
    [cellView.checkbox setEnabled:checkBoxEnabled];
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

@end
