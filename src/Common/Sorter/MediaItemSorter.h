//
//  MediaItemSorter.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>
#import <iTunesLibrary/ITLibMediaItem.h>

#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaItemSorter : NSObject

@property (readonly) PlaylistSortColumnType sortColumn;
@property (readonly) PlaylistSortOrderType sortOrder;

#pragma mark - Initializers

- (instancetype)initWithSortColumn:(PlaylistSortColumnType)sortColumn andSortOrder:(PlaylistSortOrderType)sortOrder;

#pragma mark - Accessors

- (NSArray<ITLibMediaItem*>*)sortItems:(NSArray<ITLibMediaItem*>*)items;

@end

NS_ASSUME_NONNULL_END
