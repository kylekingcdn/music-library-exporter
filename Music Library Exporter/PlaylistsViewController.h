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

- (nullable PlaylistNode*)playlistNodeForCellView:(NSView*)cellView;

- (NSArray<ITLibPlaylist*>*)playlistsWithParentId:(nullable NSNumber*)playlistId;
- (NSArray<ITLibPlaylist*>*)topLevelPlaylists;
- (NSArray<ITLibPlaylist*>*)childrenForPlaylist:(ITLibPlaylist*)playlist;

- (PlaylistNode*)createRootNode;
- (PlaylistNode*)createNodeForPlaylist:(ITLibPlaylist*)playlist;

- (void)updateSortingButton:(NSPopUpButton*)button forPlaylist:(ITLibPlaylist*)playlist;


#pragma mark - Mutators

- (void)initPlaylistNodes;

- (IBAction)setPlaylistExcludedForCellView:(id)sender;

- (IBAction)setPlaylistSorting:(id)sender;


@end

NS_ASSUME_NONNULL_END
