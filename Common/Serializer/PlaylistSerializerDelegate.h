//
//  ExportManagerDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

@class ITLibPlaylist;

NS_ASSUME_NONNULL_BEGIN

@protocol PlaylistSerializerDelegate <NSObject>
@optional

- (void)serializedPlaylists:(NSUInteger)serialized ofTotal:(NSUInteger)total;

- (void)excludedPlaylist:(ITLibPlaylist*)playlist;

@end

NS_ASSUME_NONNULL_END
