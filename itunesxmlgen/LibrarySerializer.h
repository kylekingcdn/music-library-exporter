//
//  serializer.h
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

@interface LibrarySerializer : NSObject {

  NSUInteger currentEntityId;
  NSMutableDictionary* entityIdsDicts;
}

@property (readonly) NSMutableDictionary* libraryDict;
@property NSString* filePath;

+ (NSString*) getHexadecimalPersistentId:(NSNumber*)decimalPersistentId;

+ (void) dumpPropertiesForEntity: (ITLibMediaEntity*) entity;
+ (void) dumpPropertiesForEntity: (ITLibMediaEntity*) entity withoutProperties: (NSSet<NSString *> * _Nullable) excludedProperties;

+ (void) dumpLibraryPlaylists: (ITLibrary*) library;
+ (void) dumpLibraryTracks: (ITLibrary*) library;

- (void) serializeLibrary: (ITLibrary*) library;

- (NSMutableArray<NSMutableDictionary*>*) serializePlaylists: (NSArray<ITLibPlaylist*>*) playlists;
- (NSMutableDictionary*) serializePlaylist: (ITLibPlaylist*) playlistItem withId: (NSUInteger) playlistId;
- (NSMutableArray<NSMutableDictionary*>*) serializePlaylistItems: (NSArray<ITLibMediaItem*>*) trackItems;

- (NSMutableDictionary*) serializeTracks: (NSArray<ITLibMediaItem*>*) tracks;
- (NSMutableDictionary*) serializeTrack: (ITLibMediaItem*) trackItem withId: (NSUInteger) trackId;

- (void) writeDictionary;

@end

NS_ASSUME_NONNULL_END
