//
//  Utils.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import "Utils.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibPlaylist.h>

@implementation Utils

+ (NSSet<NSString*>*)getAllKeysForDictionary:(NSDictionary*)dict1 andDictionary:(NSDictionary*)dict2 {

  NSMutableSet<NSString*>* keys = [NSMutableSet setWithArray:dict1.allKeys];
  [keys addObjectsFromArray:dict2.allKeys];

  NSSet<NSString*>* immutableKeys = [keys copy];
  return immutableKeys;
}

+ (void)recursivelyCompareDictionary:(NSDictionary*)dict1 withDictionary:(NSDictionary*)dict2 exceptForKeys:(nullable NSArray<NSString*>*)ignoredKeys {

  NSSet<NSString*>* allKeys = [Utils getAllKeysForDictionary:dict1 andDictionary:dict2];

  for (NSString* key in allKeys) {

    if (![ignoredKeys containsObject:key]) {

      if (![dict2.allKeys containsObject:key]) {
        NSLog(@"dict2 is missing key: %@", key);
      }
      else if (![dict1.allKeys containsObject:key]) {
        NSLog(@"dict2 has extra key: %@", key);
      }
      else {

        id dict1Object = [dict1 objectForKey:key];
        id dict2Object = [dict2 objectForKey:key];

        // value is array
        if ([dict1Object isKindOfClass:[NSArray class]]) {

          if (![dict2Object isKindOfClass:[NSArray class]]) {
              NSLog(@"dict2 object type should be array for key: %@", key);
          }
          else {
  //          NSArray* dict1Array = dict1Object;
  //          NSArray* dict2Array = dict2Object;
            // TODO: finish me
          }
        }

        // dictionary
        else if ([dict1Object isKindOfClass:[NSDictionary class]]) {

          NSDictionary* dict1Dict = dict1Object;
          NSDictionary* dict2Dict = dict2Object;

          [Utils recursivelyCompareDictionary:dict1Dict withDictionary:dict2Dict exceptForKeys:ignoredKeys];
        }

        // standard value
        else {
          if (![dict1Object isEqual:dict2Object]) {
            NSLog(@"key: '%@' has different values: ['%@', '%@']", key, dict1Object, dict2Object);
          }
        }
      }
    }
  }
}

+ (NSDictionary*)createPersistentIdDictionaryForItems:(NSArray<NSDictionary*>*)itemsArray withPersistentIdKey:(NSString*)persistentIdKey {

  NSMutableDictionary* persistentIdDict = [NSMutableDictionary dictionary];

  for (NSDictionary* itemDict in itemsArray) {

    NSAssert([itemDict.allKeys containsObject:persistentIdKey], @"[createPersistentIdDictionaryForItems] dictionary doesn't contain '%@' key", persistentIdKey);

    NSString* itemPersistentId = [itemDict objectForKey:persistentIdKey];
    NSAssert(itemPersistentId.length > 0, @"[createPersistentIdDictionaryForItems] dictionary persistent id value is empty for key '%@'", persistentIdKey);

    [persistentIdDict setValue:itemDict forKey:itemPersistentId];
  }

  return persistentIdDict;
}

+ (NSDictionary*)createPersistentIdDictionaryForTracks:(NSArray<NSDictionary*>*)tracksArray {

  return [Utils createPersistentIdDictionaryForItems:tracksArray withPersistentIdKey:@"Persistent ID"];
}

+ (NSDictionary*)createPersistentIdDictionaryForPlaylists:(NSArray<NSDictionary*>*)playlistsArray {

  return [Utils createPersistentIdDictionaryForItems:playlistsArray withPersistentIdKey:@"Playlist Persistent ID"];
}

+ (NSString*)descriptionForExportState:(ExportState)state {

  switch (state) {

    case ExportStopped: {
        return @"Stopped";
    }
    case ExportPreparing: {
        return @"Preparing";
    }
    case ExportGeneratingTracks: {
        return @"Generating tracks";
    }
    case ExportGeneratingPlaylists: {
        return @"Generating playlists";
    }
    case ExportWritingToDisk: {
        return @"Saving to disk";
    }
    case ExportFinished: {
        return @"Finished";
    }
    case ExportError: {
        return @"Error";
    }
  }
}

+ (NSString*)descriptionForExportDeferralReason:(ExportDeferralReason)reason {

  switch (reason) {
    case ExportDeferralOnBatteryReason: {
      return @"Running on battery";
    }
    case ExportDeferralMainAppOpenReason: {
      return @"Main app open";
    }
    case ExportDeferralErrorReason: {
      return @"Error";
    }
    case ExportDeferralUnknownReason: {
      return @"Unknown";
    }
    case ExportNoDeferralReason: {
      return @"Not deferred";
    }
  }
}

+ (nullable NSString*)titleForPlaylistSortColumn:(PlaylistSortColumnType)sortColumn {

  switch (sortColumn) {
    case PlaylistSortColumnTitle: {
      return @"Title";
    }
    case PlaylistSortColumnArtist: {
      return @"Artist";
    }
    case PlaylistSortColumnAlbumArtist: {
      return @"Album Artist";
    }
    case PlaylistSortColumnDateAdded: {
      return @"Date Added";
    }
    case PlaylistSortColumnNull: {
      return nil;
    }
  }
}

+ (PlaylistSortColumnType)playlistSortColumnForTitle:(nullable NSString*)title {

  if (!title) {
    return PlaylistSortColumnNull;
  }

  if ([title isEqualToString:@"Title"]) {
    return PlaylistSortColumnTitle;
  }
  else if ([title isEqualToString:@"Artist"]) {
    return PlaylistSortColumnArtist;
  }
  else if ([title isEqualToString:@"Album Artist"]) {
    return PlaylistSortColumnAlbumArtist;
  }
  else if ([title isEqualToString:@"Date Added"]) {
    return PlaylistSortColumnDateAdded;
  }

  return PlaylistSortColumnNull;
}

+ (nullable NSString*)titleForPlaylistSortOrder:(PlaylistSortOrderType)sortOrder {

  switch (sortOrder) {
    case PlaylistSortOrderAscending: {
      return @"Ascending";
    }
    case PlaylistSortOrderDescending: {
      return @"Descending";
    }
    case PlaylistSortOrderNull: {
      return nil;
    }
  }
}

+ (PlaylistSortOrderType)playlistSortOrderForTitle:(nullable NSString*)title {

  if (!title) {
    return PlaylistSortOrderNull;
  }

  if ([title isEqualToString:@"Ascending"]) {
    return PlaylistSortOrderAscending;
  }
  else if ([title isEqualToString:@"Descending"]) {
    return PlaylistSortOrderDescending;
  }

  return PlaylistSortOrderNull;
}

@end
