//
//  PlaylistTreeGenerator.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-13.
//

#import <Foundation/Foundation.h>

@class PlaylistTreeNode;
@class PlaylistFilterGroup;

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistTreeGenerator : NSObject

@property BOOL flattenFolders;
@property (nullable, weak) PlaylistFilterGroup* filters;

- (instancetype)init;
- (instancetype)initWithFilters:(PlaylistFilterGroup*)filters;

- (PlaylistTreeNode*)generateTreeWithError:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
