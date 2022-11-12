//
//  ExportManager.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "ExportManager.h"

#import <iTunesLibrary/ITLibrary.h>

#import "ExportConfiguration.h"
#import "LibrarySerializer.h"
#import "Logger.h"
#import "MediaEntityRepository.h"
#import "MediaItemFilterGroup.h"
#import "MediaItemSerializer.h"
#import "OrderedDictionary.h"
#import "PathMapper.h"
#import "PlaylistFilterGroup.h"
#import "PlaylistKindFilter.h"
#import "PlaylistDistinguishedKindFilter.h"
#import "PlaylistMasterFilter.h"
#import "PlaylistIDFilter.h"
#import "PlaylistParentIDFilter.h"
#import "PlaylistSerializer.h"

@implementation ExportManager {

  MediaEntityRepository* _entityRepository;
  ExportConfiguration* _configuration;
  PlaylistParentIDFilter* _playlistParentIDFilter;
}

- (instancetype)initWithConfiguration:(ExportConfiguration *)configuration {

  self = [super init];

  _entityRepository = [[MediaEntityRepository alloc] init];
  _configuration = configuration;
  _playlistParentIDFilter = nil;

  _state = ExportStopped;

  return self;
}

- (PlaylistFilterGroup*) generatePlaylistFilters {

  NSArray<NSObject<PlaylistFiltering>*>* playlistFilters = [NSArray array];

  PlaylistFilterGroup* playlistFilterGroup = [[PlaylistFilterGroup alloc] initWithFilters:playlistFilters];

  PlaylistIDFilter* playlistIDFilter = [[PlaylistIDFilter alloc] initWithExcludedIDs:_configuration.excludedPlaylistPersistentIds];
  [playlistFilterGroup addFilter:playlistIDFilter];

  if (_configuration.includeInternalPlaylists) {
    [playlistFilterGroup addFilter:[[PlaylistDistinguishedKindFilter alloc] initWithInternalKinds]];
  }
  else {
    [playlistFilterGroup addFilter:[[PlaylistDistinguishedKindFilter alloc] initWithBaseKinds]];
    [playlistFilterGroup addFilter:[[PlaylistMasterFilter alloc] init]];
  }

  PlaylistKindFilter* playlistKindFilter = [[PlaylistKindFilter alloc] initWithBaseKinds];
  if (!_configuration.flattenPlaylistHierarchy) {
    [playlistKindFilter addKind:ITLibPlaylistKindFolder];

    _playlistParentIDFilter = [[PlaylistParentIDFilter alloc] initWithExcludedIDs:_configuration.excludedPlaylistPersistentIds];
    [playlistFilterGroup addFilter:_playlistParentIDFilter];
  }
  [playlistFilterGroup addFilter:playlistKindFilter];

  return playlistFilterGroup;
}

- (BOOL)exportLibrary {

  // set state to preparing
  [self setState:ExportPreparing];

  // init ITLibrary
  NSError *error = nil;
  ITLibrary* library = [ITLibrary libraryWithAPIVersion:@"1.1" options:ITLibInitOptionLazyLoadData error:&error];
  if (library == nil) {
    MLE_Log_Info(@"ExportManager [exportLibrary] error - failed to init ITLibrary. error: %@", error.localizedDescription);
    return NO;
  }

  // configure filters
  PlaylistFilterGroup* playlistFilterGroup = [self generatePlaylistFilters];
  MediaItemFilterGroup* itemFilterGroup = [[MediaItemFilterGroup alloc] initWithBaseFilters];

  // configure directory mapping
  PathMapper* pathMapper = [[PathMapper alloc] init];
  if (_configuration.remapRootDirectory) {
    [pathMapper setSearchString:_configuration.remapRootDirectoryOriginalPath];
    [pathMapper setReplaceString:_configuration.remapRootDirectoryMappedPath];
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
  MLE_Log_Info(@"ExportManager [writeLibrary] saving to: %@", _outputFileURL);
  BOOL writeSuccess = [libraryDict writeToURL:_outputFileURL error:&error];

  if (!writeSuccess) {
    MLE_Log_Info(@"ExportManager [writeLibrary] error writing dictionary");
    return NO;
  }

  return YES;
}

- (void)setState:(ExportState)state {

  _state = state;

  if (_delegate != nil && [_delegate respondsToSelector:@selector(exportStateChanged:)]) {
    [_delegate exportStateChanged:state];
  }
}

- (void)serializedItems:(NSUInteger)serialized ofTotal:(NSUInteger)total {

  if (serialized % 10 == 0 || serialized == total) {
    MLE_Log_Info(@"ExportManager [serializedItems] serializing items %lu/%lu", (unsigned long)serialized, total);

    if (_delegate != nil && [_delegate respondsToSelector:@selector(exportedItems:ofTotal:)]) {
      [_delegate exportedItems:serialized ofTotal:total];
    }
  }
}

- (void)serializedPlaylists:(NSUInteger)serialized ofTotal:(NSUInteger)total {

  MLE_Log_Info(@"ExportManager [serializedPlaylists] serializing playlists %lu/%lu", serialized, total);

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
