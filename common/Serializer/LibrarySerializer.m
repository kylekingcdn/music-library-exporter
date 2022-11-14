//
//  LibrarySerializer.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "LibrarySerializer.h"

#import <iTunesLibrary/ITLibrary.h>

#import "OrderedDictionary.h"

@implementation LibrarySerializer

- (instancetype) init {

  self = [super init];

  return self;
}

- (OrderedDictionary*)serializeLibrary:(ITLibrary*)library withItems:(OrderedDictionary*)items andPlaylists:(NSArray<OrderedDictionary*>*)playlists {

  MutableOrderedDictionary* libraryDict = [MutableOrderedDictionary dictionary];

  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:library.apiMajorVersion] forKey:@"Major Version"];
  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:library.apiMinorVersion] forKey:@"Minor Version"];

  // TODO: timezone encoding?
  [libraryDict setValue:[NSDate date] forKey:@"Date"];
  [libraryDict setValue:library.applicationVersion forKey:@"Application Version"];
  [libraryDict setValue:[NSNumber numberWithUnsignedInteger:library.features] forKey:@"Features"];
  [libraryDict setValue:@(library.showContentRating) forKey:@"Show Content Ratings"];

  if (_persistentID != nil) {
    [libraryDict setValue:_persistentID forKey:@"Library Persistent ID"];
  }
  if (_musicLibraryDir != nil && _musicLibraryDir.length > 0) {
    [libraryDict setValue:[[NSURL fileURLWithPath:_musicLibraryDir] absoluteString] forKey:@"Music Folder"];
  }

  // set tracks/items
  [libraryDict setObject:items forKey:@"Tracks"];

  // set playlists
  [libraryDict setObject:playlists forKey:@"Playlists"];

  return libraryDict;
}

@end
