//
//  ExportDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import "ExportDelegate.h"

#import <iTunesLibrary/ITLibrary.h>

#import "Logger.h"
#import "Defines.h"
#import "Utils.h"
#import "UserDefaultsExportConfiguration.h"
#import "LibraryFilter.h"
#import "LibrarySerializer.h"
#import "OrderedDictionary.h"


@implementation ExportDelegate {

  ITLibrary* _library;

  LibraryFilter* _libraryFilter;
  LibrarySerializer* _librarySerializer;
}


#pragma mark - Initializers -

- (instancetype)initWithLibrary:(ITLibrary*)library {

  self = [super init];

  _state = ExportStopped;

  _library = library;

  _libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
  _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];

  return self;
}


#pragma mark - Mutators -

- (void)updateState:(ExportState)state {

  _state = state;

  if (_stateCallback) {
    _stateCallback(_state);
  }
}

- (BOOL)prepareForExport {

  MLE_Log_Info(@"ExportDelegate [prepareForExport]");

  // validate state
  switch (_state) {
    case ExportStopped:
    case ExportFinished:
    case ExportError: {
      break;
    }
    case ExportPreparing:
    case ExportGeneratingTracks:
    case ExportGeneratingPlaylists:
    case ExportWritingToDisk: {
      MLE_Log_Info(@"ExportDelegate [prepareForExport] currently busy - state: %@", [Utils descriptionForExportState:_state]);
      return NO;
    }
  }

  [self updateState:ExportPreparing];

  // set configuration
  if (!UserDefaultsExportConfiguration.sharedConfig.isOutputDirectoryValid) {
    MLE_Log_Info(@"ExportDelegate [prepareForExport] error - invalid output directory url");
    [self updateState:ExportError];
    return NO;
  }
  if (!UserDefaultsExportConfiguration.sharedConfig.isOutputFileNameValid) {
    MLE_Log_Info(@"ExportDelegate [prepareForExport] error - invalid output filename");
    [self updateState:ExportError];
    return NO;
  }

  // init serializer
  [_librarySerializer initSerializeMembers];

  // get included items
  _includedTracks = [_libraryFilter getIncludedTracks];
  _includedPlaylists = [_libraryFilter getIncludedPlaylists];

  return YES;
}

- (void)exportLibrary {

  MLE_Log_Info(@"ExportDelegate [exportLibrary]");

  // validate state
  switch (_state) {
    case ExportPreparing: {
      break;
    }
    case ExportStopped:
    case ExportFinished:
    case ExportError: {
      MLE_Log_Info(@"ExportDelegate [exportLibrary] error - prepareForExport must be called first - current state: %@", [Utils descriptionForExportState:_state]);
      return;
    }
    case ExportGeneratingTracks:
    case ExportGeneratingPlaylists:
    case ExportWritingToDisk: {
      MLE_Log_Info(@"ExportDelegate [exportLibrary] delegate is currently busy - state: %@", [Utils descriptionForExportState:_state]);
      return;
    }
  }

  // serialize tracks
  MLE_Log_Info(@"ExportDelegate [exportLibrary] serializing tracks");
  [self updateState:ExportGeneratingTracks];
  OrderedDictionary* tracks = [_librarySerializer serializeTracks:_includedTracks withProgressCallback:_trackProgressCallback];

  // serialize playlists
  MLE_Log_Info(@"ExportDelegate [exportLibrary] serializing playlists");
  [self updateState:ExportGeneratingPlaylists];
  NSArray<OrderedDictionary*>* playlists = [_librarySerializer serializePlaylists:_includedPlaylists withProgressCallback:_playlistProgressCallback];

  // serialize library
  MLE_Log_Info(@"ExportDelegate [exportLibrary] serializing library");
  OrderedDictionary* library = [_librarySerializer serializeLibraryforTracks:tracks andPlaylists:playlists];

  // write library
  MLE_Log_Info(@"ExportDelegate [exportLibrary] writing library");
  [self updateState:ExportWritingToDisk];
  BOOL writeSuccess = [self writeDictionary:library];

  if (writeSuccess) {
    [self updateState:ExportFinished];
  }
  else {
    [self updateState:ExportError];
  }
}

- (BOOL)writeDictionary:(OrderedDictionary*)libraryDict {

  MLE_Log_Info(@"ExportDelegate [writeDictionary]");

  NSURL* outputDirectoryUrl = UserDefaultsExportConfiguration.sharedConfig.resolveAndAutoRenewOutputDirectoryUrl;
  if (outputDirectoryUrl == nil) {
    MLE_Log_Info(@"ExportDelegate [writeDictionary] unable to retrieve output directory - a directory must be selected to obtain write permission");
    return NO;
  }

  // write library
  MLE_Log_Info(@"ExportDelegate [writeDictionary] saving to: %@", UserDefaultsExportConfiguration.sharedConfig.outputFileUrl);
  [outputDirectoryUrl startAccessingSecurityScopedResource];
  NSError* writeError;
  BOOL writeSuccess = [libraryDict writeToURL:UserDefaultsExportConfiguration.sharedConfig.outputFileUrl error:&writeError];
  [outputDirectoryUrl stopAccessingSecurityScopedResource];

  if (!writeSuccess) {
    MLE_Log_Info(@"ExportDelegate [writeDictionary] error writing dictionary");
    return NO;
  }

  return YES;
}

@end

