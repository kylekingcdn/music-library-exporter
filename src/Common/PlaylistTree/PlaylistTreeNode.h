//
//  PlaylistTreeNode.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import <Foundation/Foundation.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistTreeNode : NSObject


#pragma mark - Properties

@property NSArray<PlaylistTreeNode*>* children;

@property (nullable, nonatomic, copy) NSString* customSortProperty;
@property (nonatomic, assign) PlaylistSortOrderType customSortOrder;

@property (nullable, readonly, nonatomic, copy) NSString* persistentHexID;
@property (nullable, readonly, nonatomic, copy) NSString* parentPersistentHexID;
@property (nullable, readonly, nonatomic, copy) NSString* name;
@property (readonly, nonatomic, assign) ITLibDistinguishedPlaylistKind distinguishedKind;
@property (readonly, nonatomic, assign) ITLibPlaylistKind kind;
@property (readonly, nonatomic, assign, getter=isMaster) BOOL master;


#pragma mark - Initializers

- (instancetype)init;

+ (PlaylistTreeNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist;
+ (PlaylistTreeNode*)nodeWithPlaylist:(nullable ITLibPlaylist*)playlist andChildren:(NSArray<PlaylistTreeNode*>*)childNodes;


#pragma mark - Accessors

- (NSString*)kindDescription;
- (NSString*)itemsDescription;


@end


NS_ASSUME_NONNULL_END
