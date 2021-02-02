//
//  main.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import <iTunesLibrary/ITLibrary.h>

#import "Utils.h"
#import "LibraryParser.h"
#import "LibrarySerializer.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    if (argc != 3) {
      NSLog(@"usage: library-generator [output_xml_path] [itunes_generated_xml_path]");
      return -1;
    }

    /* parse args */
    NSString* exportedLibraryFilePath = [NSString stringWithUTF8String:argv[1]];
    NSString* exportedLibraryDir = [exportedLibraryFilePath stringByDeletingLastPathComponent];
    NSString* sourceLibraryFilePath = [NSString stringWithUTF8String:argv[2]];

    /* validate args */
    BOOL exportedLibraryDirIsDir;
    BOOL exportedLibraryDirExists = [[NSFileManager defaultManager] fileExistsAtPath:exportedLibraryDir isDirectory:&exportedLibraryDirIsDir];
    BOOL sourceLibraryFileExists = [[NSFileManager defaultManager] fileExistsAtPath:sourceLibraryFilePath];

    /* log errors */
    if (!exportedLibraryDirExists || !exportedLibraryDirIsDir) {
      NSLog(@"error - directory for generated xml doesn't exist: '%@'", exportedLibraryDir);
      return -1;
    }
    if (!sourceLibraryFileExists) {
      NSLog(@"error - library xml from iTunes not found at path: '%@'", sourceLibraryFilePath);
      return -1;
    }

    // temporary run-time flags
    BOOL generateNewLibrary = YES;
    BOOL comparePlaylistDicts = YES;
    BOOL compareTrackDicts = YES;

    // initialize library handler
    NSError *error = nil;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];
    if (!library) {
      NSLog(@"error - failed to init ITLibrary. error: %@", error.localizedDescription);
      return -1;
    }

    /* -- generated library serialization/parsing -- */

    // generate library dictionary via iTunesLibrary framework
    if (generateNewLibrary) {

      LibrarySerializer* serializer = [LibrarySerializer alloc];

      // specify playlist options
      [serializer setIncludeInternalPlaylists:YES];
      [serializer setFlattenPlaylistHierarchy:NO];
      [serializer setIncludeFoldersWhenFlattened:NO];
      [serializer setExcludedPlaylistPersistentIds:@[ ]];
      [serializer setMusicOnly:YES];

      // specify track path re-mapping options
      [serializer setRemapRootDirectory:NO];
      //[serializer setOriginalRootDirectory:@"/Users/Kyle/Music/Music/Media.localized/Music"];
      //[serializer setMappedRootDirectory:@"/data/music"];

      // generate
      [serializer serializeLibrary:library];

      [serializer setFilePath:exportedLibraryFilePath];
      [serializer writeDictionary];
    }

    // Parse generated library
    LibraryParser* generatedLibraryParser = [LibraryParser alloc];
    [generatedLibraryParser setLibraryDictionaryWithPropertyList:exportedLibraryFilePath];

    /* -- source dictionary parsing -- */

    LibraryParser* sourceLibraryParser = [LibraryParser alloc];
    [sourceLibraryParser setLibraryDictionaryWithPropertyList:sourceLibraryFilePath];

    /* -- library comparison/validation -- */

    if (compareTrackDicts) {

      NSArray<NSString*>* excludedTrackKeys = @[
        @"Track Type", @"File Type", // invalid values
        @"Purchased", @"Matched", @"Apple Music", @"Disabled", @"Playlist Only", // invalid values
        @"Date Modified", @"Date Added", @"Play Date UTC", @"Play Date", @"Skip Date", // FIXME: invalid values? offset by 1hr?
        @"Track ID", // unavailable, custom ID generated
        @"File Folder Count", @"Library Folder Count", @"Artwork Count", // unavailable
        @"Work", @"Movement Number", @"Movement Count", @"Movement Name", // unavailable
        @"Loved", @"Disliked", @"Album Loved",  @"Album Disliked", // unavailable
        @"Explicit", // unavailable
      ];
      NSDictionary* sourceLibraryTrackIdsDict = [sourceLibraryParser libraryTracksPersistentIdDictionary];
      NSDictionary* generatedLibraryTrackIdsDict = [generatedLibraryParser libraryTracksPersistentIdDictionary];

      [Utils recursivelyCompareDictionary:sourceLibraryTrackIdsDict withDictionary:generatedLibraryTrackIdsDict exceptForKeys:excludedTrackKeys];
    }

    if (comparePlaylistDicts) {

      NSArray<NSString*>* excludedPlaylistKeys = @[ @"Description", @"Smart Info", @"Smart Criteria", @"Playlist ID" ]; // unavailable
      NSDictionary* sourceLibraryPlaylistIdsDict = [sourceLibraryParser libraryPlaylistsPersistentIdDictionary];
      NSDictionary* generatedLibraryPlaylistIdsDict = [generatedLibraryParser libraryPlaylistsPersistentIdDictionary];

      [Utils recursivelyCompareDictionary:sourceLibraryPlaylistIdsDict withDictionary:generatedLibraryPlaylistIdsDict exceptForKeys:excludedPlaylistKeys];
    }
  }

  return 0;
}

