//
//  PlaylistParentIDFilter.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>

#import "PlaylistFiltering.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistParentIDFilter : NSObject<PlaylistFiltering>

- (instancetype)init;
- (instancetype)initWithExcludedIDs:(NSSet<NSString*>*)excludedIDs;

- (void)addExcludedID:(NSNumber*)playlistID;
- (void)removeExcludedID:(NSNumber*)playlistID;

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist;

@end

NS_ASSUME_NONNULL_END
