//
//  PlaylistFilterGroup.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>

@class ITLibPlaylist;
@protocol PlaylistFiltering;

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistFilterGroup : NSObject

- (instancetype)init;
- (instancetype)initWithFilters:(NSArray<NSObject<PlaylistFiltering>*>*)filters;
- (instancetype)initWithBaseFiltersAndIncludeInternal:(BOOL)includeInternal andFlattenPlaylists:(BOOL)flatten;

- (void)setFilters:(NSArray<NSObject<PlaylistFiltering>*>*)filters;

- (void)addFilter:(NSObject<PlaylistFiltering>*)filter;
- (void)removeFilter:(NSObject<PlaylistFiltering>*)filter;

- (BOOL)filtersPassForPlaylist:(ITLibPlaylist*)playlist;

@end

NS_ASSUME_NONNULL_END
