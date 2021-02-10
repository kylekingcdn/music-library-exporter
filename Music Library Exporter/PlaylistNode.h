//
//  PlaylistNode.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import <Foundation/Foundation.h>

#import <iTunesLibrary/ITLibPlaylist.h>

NS_ASSUME_NONNULL_BEGIN


@interface PlaylistNode : NSObject


#pragma mark - Properties

@property ITLibPlaylist* playlist;
@property NSArray<PlaylistNode*>* children;

@property (copy) NSString* title;

@property (readonly) BOOL isLeaf;


#pragma mark - Initializers

- (instancetype)init;

+ (PlaylistNode*)nodeWithPlaylist:(ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistNode*>*)childNodes;


#pragma mark - Accessors

- (NSString*)kindDescription;
- (NSString*)itemsDescription;


@end


NS_ASSUME_NONNULL_END
