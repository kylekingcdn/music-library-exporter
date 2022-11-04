//
//  MediaItemSerializer.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>
#import "MediaItemSerializerDelegate.h"

@class ITLibMediaItem;
@class MediaEntityRepository;
@class MediaItemFilterGroup;
@class PathMapper;
@class OrderedDictionary;

NS_ASSUME_NONNULL_BEGIN

@interface MediaItemSerializer : NSObject

@property (nullable, weak) NSObject<MediaItemSerializerDelegate>* delegate;

@property (nullable) MediaItemFilterGroup* itemFilters;
@property PathMapper* pathMapper;

- (instancetype) initWithEntityRepository:(MediaEntityRepository*)entityRepository;

- (OrderedDictionary*)serializeItems:(NSArray<ITLibMediaItem*>*)items;
- (OrderedDictionary*)serializeItem:(ITLibMediaItem*)item;

@end

NS_ASSUME_NONNULL_END
