//
//  PlaylistsViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

#import "Defines.h"

@class UserDefaultsExportConfiguration;
@class PlaylistTreeNode;

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistsViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

typedef NS_ENUM(NSUInteger, TableColumnType) {
  NullColumn = 0,
  TitleColumn,
  KindColumn,
  ItemsColumn,
  SortingColumn
};


#pragma mark - Initializers

- (instancetype)init;
- (instancetype)initWithExportConfiguration:(UserDefaultsExportConfiguration*)exportConfiguration;


#pragma mark - Accessors

+ (TableColumnType)columnWithIdentifier:(NSString*)columnIdentifier;

+ (nullable NSString*)cellViewIdentifierForColumn:(TableColumnType)column;
+ (nullable NSString*)cellTitleForColumn:(TableColumnType)column andNode:(PlaylistTreeNode*)node;

+ (PlaylistSortColumnType)playlistSortColumnForMenuItemTag:(NSInteger)tag;
+ (PlaylistSortOrderType)playlistSortOrderForMenuItemTag:(NSInteger)tag;

+ (NSInteger)menuItemTagForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn;
+ (NSInteger)menuItemTagForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder;

- (BOOL)isNodeParentExcluded:(nullable PlaylistTreeNode*)node;
- (BOOL)isNodeExcluded:(nullable PlaylistTreeNode*)node;

- (nullable PlaylistTreeNode*)playlistNodeForCellView:(NSView*)cellView;

- (void)updateSortingButton:(NSPopUpButton*)button forNode:(PlaylistTreeNode*)node;


#pragma mark - Mutators

- (void)initPlaylistNodes;

- (IBAction)setPlaylistExcludedForCellView:(id)sender;

- (IBAction)setPlaylistSorting:(id)sender;


@end

NS_ASSUME_NONNULL_END
