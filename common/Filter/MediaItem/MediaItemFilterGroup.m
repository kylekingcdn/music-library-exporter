//
//  MediaItemFilterGroup.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "MediaItemFilterGroup.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "MediaItemFiltering.h"
#import "MediaItemKindFilter.h"

@implementation MediaItemFilterGroup {

  NSMutableArray<NSObject<MediaItemFiltering>*>* _filters;
}

- (instancetype)init {

  return [self initWithFilters:[NSArray array]];
}

- (instancetype)initWithFilters:(NSArray<NSObject<MediaItemFiltering>*>*)filters {

  if (self = [super init]) {
    [self setFilters:filters];
    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithBaseFilters {

  NSMutableArray<NSObject<MediaItemFiltering>*>* baseFilters = [NSMutableArray array];

  [baseFilters addObject:[[MediaItemKindFilter alloc] initWithBaseKinds]];

  return [self initWithFilters:baseFilters];
}

- (void)setFilters:(NSArray<NSObject<MediaItemFiltering>*>*)filters {

  _filters = [filters mutableCopy];
}

- (void)addFilter:(NSObject<MediaItemFiltering>*)filter {

  NSAssert(![_filters containsObject:filter], @"MediaItemFilterGroup already contains specified filter");

  [_filters addObject:filter];
}

- (void)removeFilter:(NSObject<MediaItemFiltering>*)filter {

  NSAssert([_filters containsObject:filter], @"MediaItemFilterGroup does not contain specified filter");

  [_filters removeObject:filter];
}

- (BOOL)filtersPassForItem:(ITLibMediaItem*)item {

  for (NSObject<MediaItemFiltering>* filter in _filters) {
    if (![filter filterPassesForItem:item]) {
      return NO;
    }
  }

  return YES;
}

@end
