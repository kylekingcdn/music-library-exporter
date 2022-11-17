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

  if (self = [super init]) {

    _includedKinds = [NSMutableSet set];

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithKinds:(NSSet<NSNumber*>*)kinds {

  if (self = [self init]) {

    _includedKinds = [kinds mutableCopy];

    return self;
  }
  else {
    return nil;
  }
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
