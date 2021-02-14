//
//  main.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import <iTunesLibrary/ITLibrary.h>

#import "Utils.h"
#import "OrderedDictionary.h"
#import "LibraryFilter.h"
#import "LibrarySerializer.h"
#import "ExportConfiguration.h"
#import "ExportDelegate.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    if (argc != 3) {
      NSLog(@"usage: library-generator [output_xml_path] [itunes_generated_xml_path]");
      return -1;
    }

    /* parse args */
    NSString* exportedLibraryFilePath = [NSString stringWithUTF8String:argv[1]];
    NSString* exportedLibraryDir = [exportedLibraryFilePath stringByDeletingLastPathComponent];
    NSURL* exportedLibraryFileUrl = [NSURL fileURLWithPath:exportedLibraryFilePath];
    NSString* exportedLibraryFileName = [exportedLibraryFilePath lastPathComponent];

    NSString* sourceLibraryFilePath = [NSString stringWithUTF8String:argv[2]];

    // temp
    NSString* _programCommand = @"export";

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

    // init ITLibrary
    NSError* error = nil;
    ITLibrary* _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];
    if (!_library) {
      NSLog(@"error - failed to init ITLibrary. error: %@", error.localizedDescription);
      return -1;
    }

    // init exportConfiguration
    ExportConfiguration* _exportConfiguration = [[ExportConfiguration alloc] init];

    // add call to new helper for parsing args and applying them to exportConfigibrary];
    [_exportConfiguration setOutputDirectoryUrl:exportedLibraryFileUrl];
    [_exportConfiguration setOutputFileName:exportedLibraryFileName];

    // set shared exportConfiguration
    [ExportConfiguration initSharedConfig:_exportConfiguration];

    if ([_programCommand isEqualToString:@"export"]) {

      /* prepare for export */

      NSLog(@"preparing for export");

      LibrarySerializer* _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];
      [_librarySerializer initSerializeMembers];

      LibraryFilter* _libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
      NSArray<ITLibMediaItem*>* _includedTracks = [_libraryFilter getIncludedTracks];
      NSArray<ITLibPlaylist*>* _includedPlaylists = [_libraryFilter getIncludedPlaylists];

      /* start export */

      NSLog(@"serializing tracks");
      OrderedDictionary* tracksDict = [_librarySerializer serializeTracks:_includedTracks];

      NSLog(@"serializing playlists");
      NSArray<OrderedDictionary*>* playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists];

      NSLog(@"serializing library");
      OrderedDictionary* libraryDict = [_librarySerializer serializeLibraryforTracks:tracksDict andPlaylists:playlistsArr];

      NSLog(@"writing to file");
      BOOL writeSuccess = [libraryDict writeToURL:exportedLibraryFileUrl atomically:YES];
      if (!writeSuccess) {
        NSLog(@"error writing dictionary");
        return -1;
      }
    }
  }

  return 0;
}

