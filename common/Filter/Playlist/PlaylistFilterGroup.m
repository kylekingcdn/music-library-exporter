//
//  PlaylistFilterGroup.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistFilterGroup.h"

#import "PlaylistFiltering.h"

@implementation PlaylistFilterGroup {

  NSMutableArray<NSObject<PlaylistFiltering>*>* _filters;
}

- (instancetype)init {

  if (self = [super init]) {
    _filters = [NSMutableArray array];
    return self;
  }
  else {
    return nil;
  }
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

- (BOOL)filtersPassForPlaylist:(ITLibPlaylist*)playlist {

  for (NSObject<PlaylistFiltering>* filter in _filters) {
    if (![filter filterPassesForPlaylist:playlist]) {
      return NO;
    }
  }

  return YES;
}

@end
