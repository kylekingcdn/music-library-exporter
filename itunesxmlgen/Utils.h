//
//  Utils.h
//  itunesxmlgen
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

@class ITLibrary;
@class ITLibMediaEntity;
@class ITLibMediaItem;
@class ITLibPlaylist;
@class ITLibArtist;

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (NSDictionary*) readPropertyListFromFile:(NSString*)plistFilePath;

+ (NSSet<NSString*>*) getAllKeysForDictionary:(NSDictionary*)dict1 andDictionary:(NSDictionary*)dict2;
+ (void) recursivelyCompareDictionary:(NSDictionary*)dict1 withDictionary:(NSDictionary*)dict2 exceptForKeyPaths:(nullable NSArray<NSString*>*)ignoredKeyPaths withCurrentKeyPath:(NSString*)currentKeyPath;

+ (void) compareDicts:(NSDictionary*)dict1 forDictionary:(NSDictionary*)dict2 exceptForKeys:(NSSet<NSString*>*)ignoredKeys;
+ (NSArray<NSString*>*) getDictionaryKeysWithInequalValues:(NSDictionary*)dict1 forDictionary:(NSDictionary*)dict2 exceptForKeys:(NSSet<NSString*>*)ignoredKeys;

+ (void) compareTrack:(NSDictionary*)track1Dict withTrack:(NSDictionary*)track2Dict;

+ (NSDictionary*) createPersistentIdDictionaryForItems:(NSArray<NSDictionary*>*)itemsArray withPersistentIdKey:(NSString*)persistentIdKey;
+ (NSDictionary*) createPersistentIdDictionaryForTracks:(NSArray<NSDictionary*>*)tracksArray;
+ (NSDictionary*) createPersistentIdDictionaryForPlaylists:(NSArray<NSDictionary*>*)playlistsArray;

@end

NS_ASSUME_NONNULL_END
