//
//  PlaylistsViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

#import "Defines.h"


NS_ASSUME_NONNULL_BEGIN

@class ITLibrary;
@class ITLibPlaylist;
@class ExportConfiguration;
@class PlaylistNode;


@interface PlaylistsViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

typedef NS_ENUM(NSInteger, TableColumnType) {
  NullColumn,
  TitleColumn,
  KindColumn,
  ItemsColumn,
  SortingColumn
};


#pragma mark - Initializers

- (instancetype)initWithLibrary:(ITLibrary*)library;


#pragma mark - Accessors

+ (TableColumnType)columnWithIdentifier:(NSString*)columnIdentifier;

+ (nullable NSString*)cellViewIdentifierForColumn:(TableColumnType)column;
+ (nullable NSString*)cellTitleForColumn:(TableColumnType)column andNode:(PlaylistNode*)node;

+ (PlaylistSortColumnType)playlistSortColumnForMenuItemTag:(NSInteger)tag;
+ (PlaylistSortOrderType)playlistSortOrderForMenuItemTag:(NSInteger)tag;

+ (NSInteger)menuItemTagForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn;
+ (NSInteger)menuItemTagForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder;

- (BOOL)isNodeParentExcluded:(nullable PlaylistNode*)node;
- (BOOL)isNodeExcluded:(nullable PlaylistNode*)node;

- (nullable PlaylistNode*)playlistNodeForCellView:(NSView*)cellView;

- (void)updateSortingButton:(NSPopUpButton*)button forNode:(PlaylistNode*)node;


#pragma mark - Mutators

- (void)initPlaylistNodes;

- (IBAction)setPlaylistExcludedForCellView:(id)sender;

- (IBAction)setPlaylistSorting:(id)sender;


@end

NS_ASSUME_NONNULL_END
