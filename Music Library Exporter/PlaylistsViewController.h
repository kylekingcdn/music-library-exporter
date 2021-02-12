//
//  PlaylistsViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

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


#pragma mark - Properties

@property ITLibrary* library;
@property ExportConfiguration* exportConfiguration;


#pragma mark - Initializers

- (instancetype)init;

+ (PlaylistsViewController*)controllerWithLibrary:(ITLibrary*)lib andExportConfig:(ExportConfiguration*)config;


#pragma mark - Accessors

+ (TableColumnType)columnWithIdentifier:(NSString*)columnIdentifier;

+ (nullable NSString*)cellViewIdentifierForColumn:(TableColumnType)column;
+ (nullable NSString*)cellTitleForColumn:(TableColumnType)column andNode:(PlaylistNode*)node;

- (nullable PlaylistNode*)playlistNodeForCellView:(NSView*)cellView;

- (NSArray<ITLibPlaylist*>*)playlistsWithParentId:(nullable NSNumber*)playlistId;
- (NSArray<ITLibPlaylist*>*)childrenForPlaylist:(nullable ITLibPlaylist*)playlist;

- (PlaylistNode*)createNodeForPlaylist:(nullable ITLibPlaylist*)playlist;


#pragma mark - Mutators

- (void)initPlaylistNodes;

- (IBAction)setPlaylistExcludedForCellView:(id)sender;


@end

NS_ASSUME_NONNULL_END
