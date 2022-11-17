//
//  Utils.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (nullable NSString*)hexStringForPersistentId:(nullable NSNumber*)persistentId;

+ (PlaylistSortColumnType)playlistSortColumnForTitle:(nullable NSString*)title;
+ (PlaylistSortOrderType)playlistSortOrderForTitle:(nullable NSString*)title;

+ (nullable NSString*)mediaItemPropertyForSortColumn:(PlaylistSortColumnType)sortColumn;

@end

NS_ASSUME_NONNULL_END