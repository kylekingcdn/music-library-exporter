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

  self = [super init];

  _includedKinds = [[NSMutableSet alloc] init];

  return self;
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
