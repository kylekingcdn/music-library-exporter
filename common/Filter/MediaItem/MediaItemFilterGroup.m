//
//  MediaItemFilterGroup.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "MediaItemFilterGroup.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "MediaItemFiltering.h"

@implementation MediaItemFilterGroup {

  NSMutableArray<NSObject<MediaItemFiltering>*>* _filters;
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

- (instancetype)initWithFilters:(NSArray<NSObject<MediaItemFiltering>*>*)filters {

  if (self = [super init]) {
    _filters = [filters mutableCopy];
    return self;
  }
  else {
    return nil;
  }
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
