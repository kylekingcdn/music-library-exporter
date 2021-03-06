//
//  LibraryParser.m
//  library-generator
//
//  Created by Kyle King on 2021-01-22.
//

#import "LibraryParser.h"

#import "Utils.h"


@implementation LibraryParser


#pragma mark - Accessors

- (NSArray<NSDictionary*>*)libraryTracks {

  return [[_libraryDictionary valueForKey:@"Tracks"] allValues];
}

- (NSArray<NSDictionary*>*)libraryPlaylists {

  return [_libraryDictionary valueForKey:@"Playlists"];
}

- (NSDictionary*)libraryTracksPersistentIdDictionary {

  return [Utils createPersistentIdDictionaryForItems:[self libraryTracks] withPersistentIdKey:@"Persistent ID"];
}

- (NSDictionary*)libraryPlaylistsPersistentIdDictionary {

  return [Utils createPersistentIdDictionaryForItems:[self libraryPlaylists] withPersistentIdKey:@"Playlist Persistent ID"];
}


#pragma mark - Mutators

- (void)setLibraryDictionaryWithPropertyList:(NSString * _Nonnull)plistFilePath {

  [self setLibraryDictionary:[NSDictionary dictionaryWithContentsOfFile:plistFilePath]];
}

@end
