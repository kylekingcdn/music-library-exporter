//
//  Utils.h
//  library-generator
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

+ (NSSet<NSString*>*)getAllKeysForDictionary:(NSDictionary*)dict1 andDictionary:(NSDictionary*)dict2;
+ (void)recursivelyCompareDictionary:(NSDictionary*)dict1 withDictionary:(NSDictionary*)dict2 exceptForKeys:(nullable NSArray<NSString*>*)ignoredKeys;

+ (NSDictionary*)createPersistentIdDictionaryForItems:(NSArray<NSDictionary*>*)itemsArray withPersistentIdKey:(NSString*)persistentIdKey;
+ (NSDictionary*)createPersistentIdDictionaryForTracks:(NSArray<NSDictionary*>*)tracksArray;
+ (NSDictionary*)createPersistentIdDictionaryForPlaylists:(NSArray<NSDictionary*>*)playlistsArray;

+ (NSString*)descriptionForExportState:(ExportState)state;
+ (NSString*)descriptionForExportDeferralReason:(ExportDeferralReason)reason;

+ (nullable NSString*)titleForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn;
+ (PlaylistSortColumnType)playlistSortColumnForTitle:(nullable NSString*)title;

+ (nullable NSString*)titleForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder;
+ (PlaylistSortOrderType)playlistSortOrderForTitle:(nullable NSString*)title;

+ (nullable NSString*)mediaItemPropertyForSortColumn:(PlaylistSortColumnType)sortColumn;

+ (NSComparisonResult)alphabeticallyCompareString:(NSString*)string1 withString:(NSString*)string2;
+ (NSArray<ITLibMediaItem*>*)sortMediaItems:(NSArray<ITLibMediaItem*>*)items byProperty:(NSString*)sortProperty withOrder:(PlaylistSortOrderType)order;

@end

NS_ASSUME_NONNULL_END
