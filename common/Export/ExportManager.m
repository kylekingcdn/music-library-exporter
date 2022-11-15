//
//  ExportManager.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "ExportManager.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibPlaylist.h>

#import "ExportConfiguration.h"
#import "LibrarySerializer.h"
#import "Logger.h"
#import "MediaEntityRepository.h"
#import "MediaItemFilterGroup.h"
#import "MediaItemSerializer.h"
#import "OrderedDictionary.h"
#import "PathMapper.h"
#import "PlaylistFilterGroup.h"
#import "PlaylistParentIDFilter.h"
#import "PlaylistSerializer.h"
#import "Utils.h"

@implementation ExportManager {

  MediaEntityRepository* _entityRepository;
  ExportConfiguration* _configuration;
  PlaylistParentIDFilter* _playlistParentIDFilter;
}

NSErrorDomain const __MLE_ErrorDomain_ExportManager = @"com.kylekingcdn.MusicLibraryExporter.ExportManagerErrorDomain";


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _delegate = nil;

    _state = ExportStopped;
     _outputFileURL = nil;
    
    _entityRepository = [[MediaEntityRepository alloc] init];
    _configuration = nil;
    _playlistParentIDFilter = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithConfiguration:(ExportConfiguration *)configuration {

  if (self = [self init]) {

    _configuration = configuration;

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Mutators

- (BOOL)exportLibraryWithError:(NSError**)error {

  NSAssert(_outputFileURL != nil, @"_outputFileURL cannot be nil");

  // validate configuration
  if (![self validateConfigurationWithError:error]) {
    return NO;
  }

  // set state to preparing
  [self setState:ExportPreparing];

  // init ITLibrary
  ITLibrary* library = [ITLibrary libraryWithAPIVersion:@"1.1" options:ITLibInitOptionNone error:error];
  if (library == nil) {
    MLE_Log_Info(@"ExportManager [exportLibraryWithError] error - failed to init ITLibrary. error: %@", (*error).localizedDescription);
    [self setState:ExportError];
    return NO;
  }

  // configure filters
  PlaylistFilterGroup* playlistFilterGroup = [[PlaylistFilterGroup alloc]
                                              initWithBaseFiltersAndIncludeInternal:_configuration.includeInternalPlaylists
                                              andFlattenPlaylists:_configuration.flattenPlaylistHierarchy];

  _playlistParentIDFilter = [playlistFilterGroup addFiltersForExcludedIDs:_configuration.excludedPlaylistPersistentIds
                                                      andFlattenPlaylists:_configuration.flattenPlaylistHierarchy];

  MediaItemFilterGroup* itemFilterGroup = [[MediaItemFilterGroup alloc] initWithBaseFilters];

  // configure directory mapping
  PathMapper* pathMapper = [[PathMapper alloc] init];
  if (_configuration.remapRootDirectory) {
    [pathMapper setSearchString:_configuration.remapRootDirectoryOriginalPath];
    [pathMapper setReplaceString:_configuration.remapRootDirectoryMappedPath];
    [pathMapper setAddLocalhostPrefix:_configuration.remapRootDirectoryLocalhostPrefix];
  }

  // configure item serializers
  MediaItemSerializer* itemSerializer = [[MediaItemSerializer alloc] initWithEntityRepository:_entityRepository];
  [itemSerializer setDelegate:self];
  [itemSerializer setItemFilters:itemFilterGroup];
  [itemSerializer setPathMapper:pathMapper];

  PlaylistSerializer* playlistSerializer = [[PlaylistSerializer alloc] initWithEntityRepository:_entityRepository];
  [playlistSerializer setDelegate:self];
  [playlistSerializer setPlaylistFilters:playlistFilterGroup];
  [playlistSerializer setItemFilters:itemFilterGroup];
  [playlistSerializer setFlattenFolders:_configuration.flattenPlaylistHierarchy];
  [playlistSerializer setPlaylistCustomSortColumns:_configuration.playlistCustomSortColumnDict];
  [playlistSerializer setPlaylistCustomSortOrders:_configuration.playlistCustomSortOrderDict];

  LibrarySerializer* librarySerializer = [[LibrarySerializer alloc] init];
  [librarySerializer setPersistentID:_configuration.generatedPersistentLibraryId];
  [librarySerializer setMusicLibraryDir:_configuration.musicLibraryPath];

  // generate items dict
  [self setState:ExportGeneratingTracks];
  OrderedDictionary* itemsDict = [itemSerializer serializeItems:library.allMediaItems];

  // generate playlists dicts
  [self setState:ExportGeneratingPlaylists];
  NSArray<OrderedDictionary*>* playlistsDictArr = [playlistSerializer serializePlaylists:library.allPlaylists];

  // generate library dict
  [self setState:ExportGeneratingLibrary];
  OrderedDictionary* libraryDict = [librarySerializer serializeLibrary:library withItems:itemsDict andPlaylists:playlistsDictArr];

  // write library
  [self setState:ExportWritingToDisk];
  MLE_Log_Info(@"ExportManager [exportLibraryWithError] saving to: %@", _outputFileURL);
  BOOL writeSuccess = [libraryDict writeToURL:_outputFileURL error:error];

  if (!writeSuccess) {
    MLE_Log_Info(@"ExportManager [exportLibraryWithError] error writing dictionary");
    [self setState:ExportError];
    return NO;
  }

  [self setState:ExportFinished];

  return YES;
}

- (void)setState:(ExportState)state {

  ExportState oldState = _state;

  _state = state;

  if (_delegate != nil && [_delegate respondsToSelector:@selector(exportStateChangedFrom:toState:)]) {
    [_delegate exportStateChangedFrom:oldState toState:state];
  }
}


#pragma mark - Helper functions

- (BOOL)validateConfigurationWithError:(NSError**)error {

  // validate state
  switch (_state) {
    case ExportPreparing:
    case ExportGeneratingTracks:
    case ExportGeneratingPlaylists:
    case ExportGeneratingLibrary:
    case ExportWritingToDisk: {
      MLE_Log_Info(@"ExportManager [validateConfigurationWithError] currently busy - state: %@", ExportStateNames[_state]);
      if (error) {
        *error = [self generateErrorForCode:ExportManagerErrorBusyState];
      }
      return NO;
    }
    case ExportStopped:
    case ExportFinished:
    case ExportError: {
      break;
    }
  }

  // validate output directory set
  if (_configuration.outputDirectoryUrl == nil || !_configuration.outputDirectoryUrl.isFileURL) {
    MLE_Log_Info(@"ExportManager [validateConfigurationWithError] output directory is invalid");
    if (error) {
      *error = [self generateErrorForCode:ExportManagerErrorOutputDirectoryInvalid];
    }
    [self setState:ExportError];
    return NO;
  }

  // validate music media dir set
  if (_configuration.musicLibraryPath == nil || _configuration.musicLibraryPath.length == 0) {
    MLE_Log_Info(@"ExportManager [validateConfigurationWithError] Music Media location is unset");
    if (error) {
      *error = [self generateErrorForCode:ExportManagerErrorMusicMediaLocationUnset];
    }
    [self setState:ExportError];
    return NO;
  }

  // validate path re-mapping
  if ((_configuration.remapRootDirectoryOriginalPath == nil && _configuration.remapRootDirectoryOriginalPath.length > 0) !=
      (_configuration.remapRootDirectoryMappedPath == nil && _configuration.remapRootDirectoryMappedPath.length > 0)) {

    MLE_Log_Info(@"ExportManager [validateConfigurationWithError] Both original and mapped path must be set");
    if (error) {
      *error = [self generateErrorForCode:ExportManagerErrorRemappingInvalid];
    }
    [self setState:ExportError];
    return NO;
  }

  return YES;
}

- (NSError*)generateErrorForCode:(ExportManagerErrorCode)code {

  switch (code) {
    case ExportManagerErrorBusyState: {
      return [NSError errorWithDomain:__MLE_ErrorDomain_ExportManager code:code userInfo:@{
        NSLocalizedDescriptionKey:@"Export handler is currently busy, please try again.",
      }];
    }
    case ExportManagerErrorMusicMediaLocationUnset: {
      return [NSError errorWithDomain:__MLE_ErrorDomain_ExportManager code:code userInfo:@{
        NSLocalizedDescriptionKey:@"Music Media folder location is unset",
        NSLocalizedRecoverySuggestionErrorKey:@"This value can be retreived from the Files tab of the Music application's Preferences window.",
      }];
    }
    case ExportManagerErrorOutputDirectoryInvalid: {
      return [NSError errorWithDomain:__MLE_ErrorDomain_ExportManager code:code userInfo:@{
        NSLocalizedDescriptionKey:@"Invalid output directory",
        NSLocalizedRecoverySuggestionErrorKey: @"Would you like to select a new directory?",
        NSLocalizedRecoveryOptionsErrorKey: @[ @"Browse", @"Cancel" ],
      }];
    }
    case ExportManagerErrorRemappingInvalid: {
      return [NSError errorWithDomain:__MLE_ErrorDomain_ExportManager code:code userInfo:@{
        NSLocalizedDescriptionKey:@"Path mapping incomplete",
        NSLocalizedRecoverySuggestionErrorKey:@"Please complete the missing fields or disable path mapping.",
      }];
    }
    case ExportManagerErrorUnitialized: {
      return [NSError errorWithDomain:__MLE_ErrorDomain_ExportManager code:code userInfo:@{
        NSLocalizedDescriptionKey:@"Internal error",
        NSLocalizedRecoverySuggestionErrorKey:@"Failed to initialize export handler.",
      }];
    }
    case ExportManagerErrorWriteError: {
      return nil; // NSError provided by writeDictionary
    }
  }
}


#pragma mark - MediaItemSerializerDelegate

- (void)serializedItems:(NSUInteger)serialized ofTotal:(NSUInteger)total {

  // only call delegate method on every tenth or last item
  if (serialized % 10 == 0 || serialized == total) {

    if (_delegate != nil && [_delegate respondsToSelector:@selector(exportedItems:ofTotal:)]) {
      [_delegate exportedItems:serialized ofTotal:total];
    }
  }
}


#pragma mark - PlaylistSerializerDelegate

- (void)serializedPlaylists:(NSUInteger)serialized ofTotal:(NSUInteger)total {

  if (_delegate != nil && [_delegate respondsToSelector:@selector(exportedPlaylists:ofTotal:)]) {
    [_delegate exportedPlaylists:serialized ofTotal:total];
  }
}

- (void)excludedPlaylist:(ITLibPlaylist*)playlist {

  if (_playlistParentIDFilter != nil) {
    [_playlistParentIDFilter addExcludedID:playlist.persistentID];
  }
}

@end
