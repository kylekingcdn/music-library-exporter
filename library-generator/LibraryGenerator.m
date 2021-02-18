//
//  LibraryGenerator.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-17.
//

#import "LibraryGenerator.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "Logger.h"
#import "ArgParser.h"
#import "ExportConfiguration.h"
#import "LibraryFilter.h"
#import "LibrarySerializer.h"
#import "OrderedDictionary.h"


@interface LibraryGenerator ()

- (void)printStatus:(NSString*)message;

@end


@implementation LibraryGenerator {

  LGCommandKind _command;
  ExportConfiguration* _configuration;

  ITLibrary* _library;

  NSArray<ITLibMediaItem*>* _includedTracks;
  NSArray<ITLibPlaylist*>* _includedPlaylists;

  LibrarySerializer* _librarySerializer;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  return self;
}


#pragma mark - Accessors

- (void)printHelp {

  printf("Usage: library-generator <command> [options]\n");
  // TODO: finish me
}

- (void)printStatus:(NSString*)message {

  printf("\r%-40s\r","");
  printf("Status: %s", message.UTF8String);
  fflush(stdout);
}


#pragma mark - Mutators -

- (void)run {

  MLE_Log_Info(@"LibraryGenerator [run]");

  NSError* setupError = [self setup];
  if (setupError) {
    // temporary workaround for error message response
    if (setupError.localizedDescription && setupError.code != 100) {
      printf("%s", setupError.localizedDescription.UTF8String);
    }
    return;
  }

  NSError* execError = [self execute];
  if (execError) {
    if (execError.localizedDescription) {
      printf("%s", execError.localizedDescription.UTF8String);
    }
    return;
  }
}

- (nullable NSError*)setup {

  MLE_Log_Info(@"LibraryGenerator [setup]");

  ArgParser* argParser = [ArgParser parserWithProcessInfo:[NSProcessInfo processInfo]];

  // parse args
  [argParser parse];

// TODO: use NSError directly
  // validate command
  if (![argParser validateCommand]) {
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:3 userInfo:@{ NSLocalizedDescriptionKey:argParser.commandError }];
  }

  _command = argParser.command;

  // display help
  if (_command == LGCommandKindHelp) {
    [self printHelp];
    // empty helper error message
// TODO: add custom error code enum for this so that it's not caught as an actual error by caller
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:100 userInfo:nil];;
  }

// TODO: use NSError directly
  // validate options
  if (![argParser validateOptions]) {
    NSString* errorMessage = argParser.optionsError;
    if (argParser.optionsWithErrors) {
      errorMessage = [NSString stringWithFormat:@"%@: %@", errorMessage, [argParser.optionsWithErrors componentsJoinedByString:@", "]];
    }
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:3 userInfo:@{ NSLocalizedDescriptionKey:errorMessage }];
  }

// TODO: use NSError directly
  // generate config
  _configuration = [[ExportConfiguration alloc] init];
  if (![argParser populateExportConfiguration:_configuration]) {
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:3 userInfo:@{ NSLocalizedDescriptionKey:@"An internal error occured while interpreting configuration options" }];
  }
  [ExportConfiguration initSharedConfig:_configuration];

  [_configuration dumpProperties];

  return nil;
}

- (nullable NSError*)execute {

  MLE_Log_Info(@"LibraryGenerator [execute]");

  // setup config-dependent members
  NSError* setupPostValidateMembersError = [self setupPostValidationMembers];
  if (setupPostValidateMembersError) {
    return setupPostValidateMembersError;
  }

  // execute command
  NSError* commandError = [self handleCommand];
  if (commandError) {
    return commandError;
  }

  return nil;
}

- (nullable NSError*)setupPostValidationMembers {

  MLE_Log_Info(@"LibraryGenerator [setupPostValidationMembers]");

  // init ITLibrary
  NSError* libraryError;
  _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&libraryError];
  if (!_library) {
    return libraryError;
  }

  // init LibraryFilter to fetch included media items
  LibraryFilter* libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
  _includedTracks = [libraryFilter getIncludedTracks];
  _includedPlaylists = [libraryFilter getIncludedPlaylists];

  return nil;
}

- (nullable NSError*)handleCommand {

  switch (_command) {
    case LGCommandKindExport: {
      return [self handleExportCommand];
    }
    case LGCommandKindPrint: {
      [self handlePrintCommand];
      return nil;
    }
    case LGCommandKindHelp: {
      [self printHelp];
      return nil;
    }
    case LGCommandKindUnknown: {
      return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:1 userInfo:@{ NSLocalizedDescriptionKey:@"Unknown command" }];
    }
  }
}

- (nullable NSError*)handleExportCommand {

  MLE_Log_Info(@"LibraryGenerator [handleExportCommand]");

  /* prepare for export */

  [self printStatus:@"preparing for export"];
  LibrarySerializer* _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];
  [_librarySerializer initSerializeMembers];

  /* start export */

  [self printStatus:@"serializing tracks"];
  OrderedDictionary* tracksDict = [_librarySerializer serializeTracks:_includedTracks];

  [self printStatus:@"serializing playlists"];
  NSArray<OrderedDictionary*>* playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists];

  [self printStatus:@"serializing library"];
  OrderedDictionary* libraryDict = [_librarySerializer serializeLibraryforTracks:tracksDict andPlaylists:playlistsArr];

  [self printStatus:@"writing to file"];
  BOOL writeSuccess = [libraryDict writeToURL:_configuration.outputFileUrl atomically:YES];
  if (!writeSuccess) {
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:4 userInfo:@{ NSLocalizedDescriptionKey:@"failed to write dictionary" }];
  }

  [self printStatus:@"complete\n"];

  return nil;
}

- (void)handlePrintCommand {

  // TODO: handle hierarchy
  for (ITLibPlaylist* currPlaylist in _includedPlaylists) {
    printf("%-30s  %s\n", currPlaylist.name.UTF8String, currPlaylist.persistentID.stringValue.UTF8String);
  }
}

@end
