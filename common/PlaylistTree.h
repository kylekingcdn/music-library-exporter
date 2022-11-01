//
//  PlaylistTree.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-19.
//

#import <Foundation/Foundation.h>

@class ITLibPlaylist;
@class PlaylistNode;


NS_ASSUME_NONNULL_BEGIN

@interface PlaylistTree : NSObject


#pragma mark - Properties

@property (readonly, nullable) PlaylistNode* rootNode;
@property BOOL flattened;


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Mutators

- (void)generateForSourcePlaylists:(NSArray<ITLibPlaylist*>*)sourcePlaylists;


@end

NS_ASSUME_NONNULL_END
