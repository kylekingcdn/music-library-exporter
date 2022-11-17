//
//  PlaylistFiltering.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>

@class ITLibPlaylist;

NS_ASSUME_NONNULL_BEGIN

@protocol PlaylistFiltering <NSObject>

- (BOOL)filterPassesForPlaylist:(ITLibPlaylist*)playlist;

@end

NS_ASSUME_NONNULL_END
