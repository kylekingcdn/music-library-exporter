//
//  main.m
//  itunesxmlgen
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

    NSError *error = nil;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];

    if (!library) {
      NSLog(@"error - failed to init ITLibrary. error: %@", error.localizedDescription);
      return -1;
    }

    // temporary run-time flags
    bool generateNewLibrary = NO;
    bool comparePlaylistDicts = NO;
    bool compareTrackDicts = NO;

    NSString* desktopFilePath = [NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES) firstObject];
    NSString* exportedLibraryFileName = @"exportedLibrary.xml";
    NSString* exportedLibraryFilePath = [[desktopFilePath stringByAppendingString:@"/"] stringByAppendingString:exportedLibraryFileName];


    /* -- generated library serialization/parsing -- */

    // generate library dictionary via iTunesLibrary framework
    if (generateNewLibrary) {

      LibrarySerializer* serializer = [LibrarySerializer alloc];
      [serializer serializeLibrary:library];

      [serializer setFilePath:exportedLibraryFilePath];
      [serializer writeDictionary];
    }

    // Parse generated library
    LibraryParser* generatedLibraryParser = [LibraryParser alloc];
    [generatedLibraryParser setLibraryDictionaryWithPropertyList:exportedLibraryFilePath];


    /* -- source dictionary parsing -- */

    // get dictionary for officially generated library
    NSString* sourceLibraryFileName = @"sourceLibrary.xml";
    NSString* sourceLibraryFilePath = [[desktopFilePath stringByAppendingString:@"/"] stringByAppendingString:sourceLibraryFileName];

    LibraryParser* sourceLibraryParser = [LibraryParser alloc];
    [sourceLibraryParser setLibraryDictionaryWithPropertyList:sourceLibraryFilePath];


    /* -- library comparison/validation -- */

    if (compareTrackDicts) {

      NSArray<NSString*>* excludedTrackKeys = @[
        @"Track Type", @"File Type", // invalid values
        @"Purchased", @"Matched", @"Apple Music", @"Disabled", @"Playlist Only", // invalid values
        @"Date Modified", @"Date Added", @"Play Date UTC", @"Play Date", @"Skip Date", // invalid values
        @"Track ID", // unavailable
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

      NSArray<NSString*>* excludedPlaylistKeys = @[ @"Description", @"Smart Info", @"Smart Criteria", @"Playlist ID" ];
      NSDictionary* sourceLibraryPlaylistIdsDict = [sourceLibraryParser libraryPlaylistsPersistentIdDictionary];
      NSDictionary* generatedLibraryPlaylistIdsDict = [generatedLibraryParser libraryPlaylistsPersistentIdDictionary];

      [Utils recursivelyCompareDictionary:sourceLibraryPlaylistIdsDict withDictionary:generatedLibraryPlaylistIdsDict exceptForKeys:excludedPlaylistKeys];
    }
  }

  return 0;
}

