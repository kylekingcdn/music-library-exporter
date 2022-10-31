//
//  MediaItemKindFilter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "MediaItemKindFilter.h"

@implementation MediaItemKindFilter {

  NSMutableSet<NSNumber*>* _includedKinds;
}

- (instancetype)init {

  self = [super init];

  _includedKinds = [NSMutableSet set];

  return self;
}

- (void)addKind:(ITLibMediaItemMediaKind)kind {

  [_includedKinds addObject:[NSNumber numberWithUnsignedInteger:kind]];
}

- (void)removeKind:(ITLibMediaItemMediaKind)kind {

  [_includedKinds removeObject:[NSNumber numberWithUnsignedInteger:kind]];
}

- (BOOL)filterPassesForItem:(ITLibMediaItem*)item {

  return [_includedKinds containsObject:[NSNumber numberWithUnsignedInteger:item.mediaKind]];
}

@end
