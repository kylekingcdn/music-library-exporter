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
#import "Logger.h"

void printStatus(const char* statusMessage) {

  printf("\r%-40s\r","");
  printf("Status: %s", statusMessage);
  fflush(stdout);
}

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    ArgParser* argParser = [ArgParser parserWithProcessInfo:[NSProcessInfo processInfo]];
    [argParser parse];

    // validate command
    if (![argParser validateCommand]) {
      NSString* error = argParser.commandError;
      printf("error parsing command: %s\n", error.UTF8String);
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
      printf("error interpreting options - %s\n", error.UTF8String);
      if (argParser.optionsWithErrors) {
        printf("%s\n", [argParser.optionsWithErrors componentsJoinedByString:@", "].UTF8String);
      }

      return -1;
    }

    // generate ExportConfiguration from options
    ExportConfiguration* configuration = [[ExportConfiguration alloc] init];
    if (![argParser populateExportConfiguration:configuration]) {
      printf("an internal error occured while interpreting configuration options\n");
      return -1;
    }

    [ExportConfiguration initSharedConfig:configuration];
    [configuration dumpProperties];

    // init ITLibrary
    NSError* error = nil;
    ITLibrary* _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];
    if (!_library) {
      printf("error - failed to init ITLibrary. error: %s\n", error.localizedDescription.UTF8String);
      return -1;
    }

    LibraryFilter* _libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
    NSArray<ITLibMediaItem*>* _includedTracks = [_libraryFilter getIncludedTracks];
    NSArray<ITLibPlaylist*>* _includedPlaylists = [_libraryFilter getIncludedPlaylists];

    if (command == LGCommandKindExport) {

      /* prepare for export */

      printStatus("preparing for export");
      LibrarySerializer* _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];
      [_librarySerializer initSerializeMembers];

      /* start export */

      printStatus("serializing tracks");
      OrderedDictionary* tracksDict = [_librarySerializer serializeTracks:_includedTracks];

      printStatus("serializing playlists");
      NSArray<OrderedDictionary*>* playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists];

      printStatus("serializing library");
      OrderedDictionary* libraryDict = [_librarySerializer serializeLibraryforTracks:tracksDict andPlaylists:playlistsArr];

      printStatus("writing to file");
      BOOL writeSuccess = [libraryDict writeToURL:configuration.outputFileUrl atomically:YES];
      if (!writeSuccess) {
        printf("error writing dictionary");
        return -1;
      }

      printStatus("complete\n");
    }
    else if (command == LGCommandKindPrint) {

      for (ITLibPlaylist* currPlaylist in _includedPlaylists) {
        printf("%s - %s", currPlaylist.name.UTF8String, currPlaylist.persistentID.stringValue.UTF8String);
      }
    }
  }

  return 0;
}
