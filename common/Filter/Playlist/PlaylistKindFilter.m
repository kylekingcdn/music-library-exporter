//
//  PlaylistKindFilter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistKindFilter.h"

@implementation PlaylistKindFilter {

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

  NSMutableSet<NSNumber*>* baseKinds;
  [baseKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibPlaylistKindRegular]];
  [baseKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibPlaylistKindSmart]];

  return [self initWithKinds:baseKinds];
}

- (void)addKind:(ITLibPlaylistKind)kind {

  [_includedKinds addObject:[NSNumber numberWithUnsignedInteger:kind]];
}

- (void)removeKind:(ITLibPlaylistKind)kind {

  [_includedKinds removeObject:[NSNumber numberWithUnsignedInteger:kind]];
}

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist {

  return [_includedKinds containsObject:[NSNumber numberWithUnsignedInteger:playlist.kind]];
}

@end
