//
//  Utils.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

@class ITLibrary;
@class ITLibMediaEntity;
@class ITLibMediaItem;
@class ITLibPlaylist;
@class ITLibArtist;

#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (nullable NSString*)hexStringForPersistentId:(nullable NSNumber*)persistentId;

+ (NSString*)descriptionForExportState:(ExportState)state;
+ (NSString*)descriptionForExportDeferralReason:(ExportDeferralReason)reason;

+ (nullable NSString*)titleForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn;
+ (PlaylistSortColumnType)playlistSortColumnForTitle:(nullable NSString*)title;

+ (nullable NSString*)titleForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder;
+ (PlaylistSortOrderType)playlistSortOrderForTitle:(nullable NSString*)title;

+ (nullable NSString*)mediaItemPropertyForSortColumn:(PlaylistSortColumnType)sortColumn;

@end

NS_ASSUME_NONNULL_END
