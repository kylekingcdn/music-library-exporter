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

@property PlaylistSortColumnType sortColumn;
@property PlaylistSortOrderType sortOrder;

- (instancetype)init;

- (NSArray<ITLibMediaItem*>*)sortItems:(NSArray<ITLibMediaItem*>*)items;

@end

NS_ASSUME_NONNULL_END
