//
//  MediaItemFiltering.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>

@class ITLibMediaItem;

NS_ASSUME_NONNULL_BEGIN

@protocol MediaItemFiltering <NSObject>

- (BOOL)filterPassesForItem:(ITLibMediaItem*)item;

@end

NS_ASSUME_NONNULL_END
