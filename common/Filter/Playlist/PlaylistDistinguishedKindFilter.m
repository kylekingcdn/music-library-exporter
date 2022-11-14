//
//  PlaylistDistinguishedKindFilter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import "PlaylistDistinguishedKindFilter.h"

@implementation PlaylistDistinguishedKindFilter {

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
  [baseKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindNone]];

  return [self initWithKinds:baseKinds];
}

- (instancetype)initWithInternalKinds {

  NSMutableSet<NSNumber*>* internalKinds = [NSMutableSet set];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindNone]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMusic]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindPurchases]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKind90sMusic]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindMyTopRated]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindTop25MostPlayed]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRecentlyPlayed]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindRecentlyAdded]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindClassicalMusic]];
  [internalKinds addObject:[NSNumber numberWithUnsignedInteger:ITLibDistinguishedPlaylistKindLovedSongs]];

  return [self initWithKinds:internalKinds];
}

- (void)addKind:(ITLibDistinguishedPlaylistKind)kind {

  [_includedKinds addObject:[NSNumber numberWithUnsignedInteger:kind]];
}

- (void)removeKind:(ITLibDistinguishedPlaylistKind)kind {

  [_includedKinds removeObject:[NSNumber numberWithUnsignedInteger:kind]];
}

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist {

  return [_includedKinds containsObject:[NSNumber numberWithUnsignedInteger:playlist.distinguishedKind]];
}

@end
