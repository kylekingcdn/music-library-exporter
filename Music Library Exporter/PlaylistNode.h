//
//  PlaylistNode.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import <Foundation/Foundation.h>

@class ITLibPlaylist;


NS_ASSUME_NONNULL_BEGIN

@interface PlaylistNode : NSObject


#pragma mark - Properties

@property (nullable) ITLibPlaylist* playlist;
@property NSArray<PlaylistNode*>* children;


#pragma mark - Initializers

- (instancetype)init;

+ (PlaylistNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistNode*>*)childNodes;


#pragma mark - Accessors

- (NSString*)kindDescription;
- (NSString*)itemsDescription;


@end


NS_ASSUME_NONNULL_END
