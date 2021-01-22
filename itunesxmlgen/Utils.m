//
//  Utils.m
//  itunesxmlgen
//
//  Created by Kyle King on 2021-01-18.
//

#import "Utils.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibPlaylist.h>

@implementation Utils

+ (NSDictionary*) readPropertyListFromFile:(NSString*)plistFilePath {

  return [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
}

+ (NSSet<NSString*>*) getAllKeysForDictionary:(NSDictionary*)dict1 andDictionary:(NSDictionary*)dict2 {

  NSMutableSet<NSString*>* keys = [NSMutableSet setWithArray:dict1.allKeys];
  [keys addObjectsFromArray:dict2.allKeys];

  NSSet<NSString*>* immutableKeys = [keys copy];
  return immutableKeys;
}

+ (void) recursivelyCompareDictionary:(NSDictionary*)dict1 withDictionary:(NSDictionary*)dict2 exceptForKeyPaths:(nullable NSArray<NSString*>*)ignoredKeyPaths withCurrentKeyPath:(NSString*)currentKeyPath {

  NSSet<NSString*>* allKeys = [Utils getAllKeysForDictionary:dict1 andDictionary:dict2];

  for (NSString* key in allKeys) {

    NSString* newKeyPath = [[currentKeyPath stringByAppendingString:@"/"] stringByAppendingString:key];
    NSLog(@"checking key path: %@", newKeyPath);

    if (![dict2.allKeys containsObject:key]) {
      NSLog(@"dict2 is missing key path: %@", newKeyPath);
    }
    else if (![dict1.allKeys containsObject:key]) {
      NSLog(@"dict2 has extra key path: %@", newKeyPath);
    }
    else {

      id dict1Object = [dict1 objectForKey:key];
      id dict2Object = [dict2 objectForKey:key];

      // value is array
      if ([dict1Object isKindOfClass:[NSArray class]]) {

        if (![dict2Object isKindOfClass:[NSArray class]]) {
            NSLog(@"dict2 object type should be array for key path: %@", newKeyPath);
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

        [Utils recursivelyCompareDictionary:dict1Dict withDictionary:dict2Dict exceptForKeyPaths:ignoredKeyPaths withCurrentKeyPath:newKeyPath];
      }

      // standard value
      else {
        if (![dict1Object isEqual:dict2Object]) {
          NSLog(@"key path: '%@' has different values: ['%@', '%@']", newKeyPath, dict1Object, dict2Object);
        }
      }
    }
  }
}

+ (void) compareTrack:(NSDictionary*)track1Dict withTrack:(NSDictionary*)track2Dict {

  NSSet<NSString*>* ignoredKeys = [NSSet set];

  [Utils compareDicts:track1Dict forDictionary:track2Dict exceptForKeys:ignoredKeys];
}

+ (void) compareDicts:(NSDictionary*)dict1 forDictionary:(NSDictionary*)dict2 exceptForKeys:(NSSet<NSString*>*)ignoredKeys {

  NSArray<NSString*>* inequalKeys = [Utils getDictionaryKeysWithInequalValues:dict1 forDictionary:dict2 exceptForKeys:ignoredKeys];

  for (NSString* inequalKey in inequalKeys) {
    NSLog(@"inconsitent key %@ - dict1: %@, dict2: %@", inequalKey, [dict1 objectForKey:inequalKey], [dict2 objectForKey:inequalKey]);
  }
}

+ (NSArray<NSString*>*) getDictionaryKeysWithInequalValues:(NSDictionary*)dict1 forDictionary:(NSDictionary*)dict2 exceptForKeys:(NSSet<NSString*>*)ignoredKeys {

  NSMutableArray<NSString*>* inconsistentKeys = [NSMutableArray array];

  NSMutableSet<NSString*>* allKeys = [NSMutableSet setWithArray:dict1.allKeys];
  [allKeys addObjectsFromArray:dict2.allKeys];

  for (NSString* trackKey in allKeys) {
    if (![ignoredKeys containsObject:trackKey]) {
      if ([dict1 objectForKey:trackKey] != [dict2 objectForKey:trackKey]) {
        [inconsistentKeys addObject: trackKey];
      }
    }
  }

  return inconsistentKeys;
}

+ (NSDictionary*) createPersistentIdDictionaryForItems:(NSArray<NSDictionary*>*)itemsArray withPersistentIdKey:(NSString*)persistentIdKey {

  NSDictionary* persistentIdDict = [NSMutableDictionary dictionary];

  for (NSDictionary* itemDict in itemsArray) {

    NSAssert([itemDict.allKeys containsObject:persistentIdKey], @"[createPersistentIdDictionaryForItems] dictionary doesn't contain '%@' key", persistentIdKey);

    NSString* itemPersistentId = [itemDict objectForKey:persistentIdKey];
    NSAssert(itemPersistentId.length > 0, @"[createPersistentIdDictionaryForItems] dictionary persistent id value is empty for key '%@'", persistentIdKey);

    [persistentIdDict setValue:itemDict forKey:itemPersistentId];
  }

  return persistentIdDict;
}

+ (NSDictionary*) createPersistentIdDictionaryForTracks:(NSArray<NSDictionary*>*)tracksArray {

  return [Utils createPersistentIdDictionaryForItems:tracksArray withPersistentIdKey:@"Persistent ID"];
}

+ (NSDictionary*) createPersistentIdDictionaryForPlaylists:(NSArray<NSDictionary*>*)playlistsArray {

  return [Utils createPersistentIdDictionaryForItems:playlistsArray withPersistentIdKey:@"Playlist Persistent ID"];
}

@end
