//
//  MediaItemKindFilter.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>
#import <iTunesLibrary/ITLibMediaItem.h>

#import "MediaItemFiltering.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaItemKindFilter : NSObject<MediaItemFiltering>

- (instancetype)init;
- (instancetype)initWithKinds:(NSSet<NSNumber*>*)kinds;

- (instancetype)initWithBaseKinds;

- (void)addKind:(ITLibMediaItemMediaKind)kind;
- (void)removeKind:(ITLibMediaItemMediaKind)kind;

- (BOOL)filterPassesForItem:(ITLibMediaItem*)item;

@end

NS_ASSUME_NONNULL_END
