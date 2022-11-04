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

  return [self initWithKinds:[NSSet set]];
}

- (instancetype)initWithKinds:(NSSet<NSNumber*>*)kinds {

  self = [super init];

  _includedKinds = [kinds mutableCopy];

  return self;
}

- (instancetype)initWithBaseKinds {

  NSMutableSet<NSNumber*>* baseKinds = [NSMutableSet set];
  [baseKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibMediaItemMediaKindSong]];

  return [self initWithKinds:baseKinds];
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
