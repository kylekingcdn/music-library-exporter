//
//  PlaylistDistinguishedKindFilter.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "PlaylistFiltering.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistDistinguishedKindFilter : NSObject<PlaylistFiltering>

- (instancetype)init;
- (instancetype)initWithKinds:(NSSet<NSNumber*>*)kinds;

- (instancetype)initWithBaseKinds;
- (instancetype)initWithInternalKinds;

- (void)addKind:(ITLibDistinguishedPlaylistKind)kind;
- (void)removeKind:(ITLibDistinguishedPlaylistKind)kind;

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist;

@end

NS_ASSUME_NONNULL_END
