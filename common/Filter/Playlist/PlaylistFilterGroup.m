//
//  PlaylistFilterGroup.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistFilterGroup.h"

#import "PlaylistKindFilter.h"
#import "PlaylistDistinguishedKindFilter.h"
#import "PlaylistMasterFilter.h"
#import "PlaylistIDFilter.h"
#import "PlaylistParentIDFilter.h"

@implementation PlaylistFilterGroup {

  NSMutableArray<NSObject<PlaylistFiltering>*>* _filters;
}

- (instancetype)init {

  return [self initWithFilters:[NSArray array]];
}

- (instancetype)initWithFilters:(NSArray<NSObject<PlaylistFiltering>*>*)filters {

  if (self = [super init]) {
    [self setFilters:filters];
    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithBaseFiltersAndIncludeInternal:(BOOL)includeInternal andFlattenPlaylists:(BOOL)flatten {

  if (self = [super init]) {

    _filters = [NSMutableArray array];

    // include internal
    if (includeInternal) {
      [self addFilter:[[PlaylistDistinguishedKindFilter alloc] initWithInternalKinds]];
    }
    // exclude internal
    else {
      [self addFilter:[[PlaylistDistinguishedKindFilter alloc] initWithBaseKinds]];
      [self addFilter:[[PlaylistMasterFilter alloc] init]];
    }

    PlaylistKindFilter* playlistKindFilter = [[PlaylistKindFilter alloc] initWithBaseKinds];
    // exclude folders
    if (!flatten) {
      [playlistKindFilter addKind:ITLibPlaylistKindFolder];
    }
    [self addFilter:playlistKindFilter];

    return self;
  }
  else {
    return nil;
  }
}

- (NSArray<NSObject<PlaylistFiltering>*>*)filters {

  return _filters;
}

- (void)setFilters:(NSArray<NSObject<PlaylistFiltering>*>*)filters {

  _filters = [filters mutableCopy];
}

- (void)addFilter:(NSObject<PlaylistFiltering>*)filter {

  NSAssert(![_filters containsObject:filter], @"PlaylistFilterGroup already contains specified filter");

  [_filters addObject:filter];
}

- (void)removeFilter:(NSObject<PlaylistFiltering>*)filter {

  NSAssert([_filters containsObject:filter], @"PlaylistFilterGroup does not contain specified filter");

  [_filters removeObject:filter];
}

- (PlaylistParentIDFilter*)addFiltersForExcludedIDs:(NSSet<NSString*>*)excludedIDs andFlattenPlaylists:(BOOL)flatten {

  PlaylistParentIDFilter* parentIDFilter = nil;

  // manually excluded playlists
  PlaylistIDFilter* playlistIDFilter = [[PlaylistIDFilter alloc] initWithExcludedIDs:excludedIDs];
  [self addFilter:playlistIDFilter];

  // exclude parent folders that have been manually excluded
  if (!flatten) {
    parentIDFilter = [[PlaylistParentIDFilter alloc] initWithExcludedIDs:excludedIDs];
    [self addFilter:parentIDFilter];
  }

  return parentIDFilter;
}

- (BOOL)filtersPassForPlaylist:(ITLibPlaylist*)playlist {

  for (NSObject<PlaylistFiltering>* filter in _filters) {
    if (![filter filterPassesForPlaylist:playlist]) {
      
      return NO;
    }
  }

  return YES;
}

@end
