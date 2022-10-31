//
//  MediaItemFilterGroup.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-10-31.
//

#import <Foundation/Foundation.h>

@class ITLibMediaItem;
@protocol MediaItemFiltering;

NS_ASSUME_NONNULL_BEGIN

@interface MediaItemFilterGroup : NSObject

- (instancetype)initWithFilters:(NSArray<NSObject<MediaItemFiltering>*>*)filters;

- (void)addFilter:(NSObject<MediaItemFiltering>*)filter;
- (void)removeFilter:(NSObject<MediaItemFiltering>*)filter;

- (BOOL)filtersPassForItem:(ITLibMediaItem*)item;

@end

NS_ASSUME_NONNULL_END
