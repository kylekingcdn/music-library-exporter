//
//  PlaylistKindFilter.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "PlaylistFiltering.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistKindFilter : NSObject<PlaylistFiltering>

- (instancetype)init;

- (void)addKind:(ITLibPlaylistKind)kind;
- (void)removeKind:(ITLibPlaylistKind)kind;

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist;

@end

NS_ASSUME_NONNULL_END
