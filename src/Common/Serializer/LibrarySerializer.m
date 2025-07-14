//
//  LibrarySerializer.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "LibrarySerializer.h"

#import <iTunesLibrary/ITLibrary.h>
#import <OSLog/OSLog.h>

#import "OrderedDictionary.h"

@implementation LibrarySerializer

- (instancetype)init {

  if (self = [super init]) {

    _persistentID = nil;
    _musicLibraryDir = nil;
    
    return self;
  }
  else {
    return nil;
  }
}

- (OrderedDictionary*)serializeLibrary:(ITLibrary*)library withItems:(OrderedDictionary*)items andPlaylists:(NSArray<OrderedDictionary*>*)playlists {

  os_log_debug(OS_LOG_DEFAULT, "Serializing library dict - '%{public}@'. (item count: %lu, top-level playlist count: %lu)", library.musicFolderLocation, items.count, playlists.count);

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
    NSString* musicFolderUrlStr = [[NSURL fileURLWithPath:_musicLibraryDir] absoluteString];
    if (musicFolderUrlStr != nil) {
      os_log_info(OS_LOG_DEFAULT, "Setting library dict 'Music Folder' to absolute path URL '%{public}@' derived from '%{public}@'", musicFolderUrlStr, _musicLibraryDir );
      [libraryDict setValue:musicFolderUrlStr forKey:@"Music Folder"];
    } else {
      os_log_fault(OS_LOG_DEFAULT, "Derived Music folder URL is NIL despite input music library path passing included checks (path: '%{public}@')", _musicLibraryDir);
    }
  }
  else {
    os_log_info(OS_LOG_DEFAULT, "Skipping library dict 'Music Folder', Music library directory is either NULL or empty");
  }

  // set tracks/items
  [libraryDict setObject:items forKey:@"Tracks"];

  // set playlists
  [libraryDict setObject:playlists forKey:@"Playlists"];

  os_log_debug(OS_LOG_DEFAULT, "Finished serializing library");

  return libraryDict;
}

@end
