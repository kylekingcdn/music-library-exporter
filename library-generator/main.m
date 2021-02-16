//
//  main.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "Utils.h"
#import "OrderedDictionary.h"
#import "LibraryFilter.h"
#import "LibrarySerializer.h"
#import "ExportConfiguration.h"
#import "ExportDelegate.h"
#import "ArgParser.h"
#import "XPMArguments.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    ArgParser* argParser = [ArgParser parserWithProcessInfo:[NSProcessInfo processInfo]];
    [argParser parse];

    // validate command
    if (![argParser validateCommand]) {
      NSString* error = argParser.commandError;
      NSLog(@"error parsing command: %@", error);
      return -1;
    }

    LGCommandKind command = argParser.command;

    // display help
    if (command == LGCommandKindHelp) {
      [argParser displayHelp];
      return 0;
    }

    // validate options
    if (![argParser validateOptions]) {
      NSString* error = argParser.optionsError;
      NSLog(@"error interpreting options - %@", error);
      if (argParser.optionsWithErrors) {
        NSLog(@"%@", [argParser.optionsWithErrors componentsJoinedByString:@", "]);
      }

      return -1;
    }

    // generate ExportConfiguration from options
    ExportConfiguration* configuration = [[ExportConfiguration alloc] init];
    if (![argParser populateExportConfiguration:configuration]) {
      NSLog(@"an internal error occured while interpreting configuration options");
      return -1;
    }

    [ExportConfiguration initSharedConfig:configuration];
    [configuration dumpProperties];

    // init ITLibrary
    NSError* error = nil;
    ITLibrary* _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];
    if (!_library) {
      NSLog(@"error - failed to init ITLibrary. error: %@", error.localizedDescription);
      return -1;
    }

    LibraryFilter* _libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
    NSArray<ITLibMediaItem*>* _includedTracks = [_libraryFilter getIncludedTracks];
    NSArray<ITLibPlaylist*>* _includedPlaylists = [_libraryFilter getIncludedPlaylists];

    if (command == LGCommandKindExport) {

      /* prepare for export */

      NSLog(@"preparing for export");

      LibrarySerializer* _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];
      [_librarySerializer initSerializeMembers];

      /* start export */

      NSLog(@"serializing tracks");
      OrderedDictionary* tracksDict = [_librarySerializer serializeTracks:_includedTracks];

      NSLog(@"serializing playlists");
      NSArray<OrderedDictionary*>* playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists];

      NSLog(@"serializing library");
      OrderedDictionary* libraryDict = [_librarySerializer serializeLibraryforTracks:tracksDict andPlaylists:playlistsArr];

      NSLog(@"writing to file");
      BOOL writeSuccess = [libraryDict writeToURL:configuration.outputFileUrl atomically:YES];
      if (!writeSuccess) {
        NSLog(@"error writing dictionary");
        return -1;
      }
    }
    else if (command == LGCommandKindPrint) {

      for (ITLibPlaylist* currPlaylist in _includedPlaylists) {
        NSLog(@"%@ - %@", currPlaylist.name, currPlaylist.persistentID);
      }
    }
  }

  return 0;
}

