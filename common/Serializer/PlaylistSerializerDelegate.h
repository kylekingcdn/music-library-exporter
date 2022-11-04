//
//  ExportManagerDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlaylistSerializerDelegate <NSObject>
@optional

- (void)serializedPlaylists:(NSUInteger)serialized ofTotal:(NSUInteger)total;

@end

NS_ASSUME_NONNULL_END
