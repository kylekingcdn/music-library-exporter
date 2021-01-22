//
//  LibraryParser.h
//  itunesxmlgen
//
//  Created by Kyle King on 2021-01-22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LibraryParser : NSObject

@property NSDictionary* libraryDictionary;

- (void) setLibraryDictionaryWithPropertyList:(NSString * _Nonnull)plistFilePath;

- (NSArray<NSDictionary*>*) libraryTracks;
- (NSArray<NSDictionary*>*) libraryPlaylists;

- (NSDictionary*) libraryTracksPersistentIdDictionary;
- (NSDictionary*) libraryPlaylistsPersistentIdDictionary;

@end

NS_ASSUME_NONNULL_END
