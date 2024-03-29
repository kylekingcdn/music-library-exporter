//
//  PlaylistsViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

#import "Defines.h"

@class ExportConfiguration;
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
- (instancetype)initWithExportConfiguration:(ExportConfiguration*)exportConfiguration;


#pragma mark - Accessors

+ (TableColumnType)columnWithIdentifier:(NSString*)columnIdentifier;

+ (nullable NSString*)cellViewIdentifierForColumn:(TableColumnType)column;
+ (nullable NSString*)cellTitleForColumn:(TableColumnType)column andNode:(PlaylistTreeNode*)node;

+ (nullable NSString*)playlistSortPropertyForMenuItemTag:(NSInteger)tag;
+ (PlaylistSortOrderType)playlistSortOrderForMenuItemTag:(NSInteger)tag;

+ (NSInteger)menuItemTagForPlaylistSortProperty:(nullable NSString*)sortProperty;
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
