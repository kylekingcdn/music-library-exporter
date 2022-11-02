//
//  ExportManager.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "ExportManager.h"

#import <iTunesLibrary/ITLibrary.h>

#import "UserDefaultsExportConfiguration.h"
#import "LibrarySerializer.h"
#import "Logger.h"
#import "MediaEntityRepository.h"
#import "MediaItemFilterGroup.h"
#import "MediaItemSerializer.h"
#import "OrderedDictionary.h"
#import "PathMapper.h"
#import "PlaylistFilterGroup.h"
#import "PlaylistSerializer.h"

@implementation ExportManager {

  MediaEntityRepository* _entityRepository;

  PathMapper* _pathMapper;

  PlaylistFilterGroup* _playlistFilters;
  MediaItemFilterGroup* _itemFilters;
}

- (instancetype)init {

  return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(nullable NSObject<ExportManagerDelegate> *)delegate {

  self = [super init];

  [self setDelegate:delegate];

  _entityRepository = [[MediaEntityRepository alloc] init];

  _pathMapper = [[PathMapper alloc] init];

  _playlistFilters = [[PlaylistFilterGroup alloc] init];
  _itemFilters = [[MediaItemFilterGroup alloc] init];

  return self;
}

- (void)configure {

  NSArray<NSObject<PlaylistFiltering>*>* playlistFilters = [NSArray array]; // TODO: configure
  [_playlistFilters setFilters:playlistFilters];

  NSArray<NSObject<MediaItemFiltering>*>* itemFilters = [NSArray array]; // TODO: configure
  [_itemFilters setFilters:itemFilters];

  [_pathMapper setSearchString:@""]; // TODO: configure
  [_pathMapper setReplaceString:@""]; // TODO: configure
}

- (BOOL)exportLibrary {

  // init ITLibrary
  NSError *error = nil;
  ITLibrary* library = [ITLibrary libraryWithAPIVersion:@"1.1" options:ITLibInitOptionLazyLoadData error:&error];
  if (library == nil) {
    MLE_Log_Info(@"ExportManager [exportLibrary] error - failed to init ITLibrary. error: %@", error.localizedDescription);
    return NO;
  }

  MediaItemSerializer* itemSerializer = [[MediaItemSerializer alloc] initWithEntityRepository:_entityRepository];
  [itemSerializer setDelegate:self];
  [itemSerializer setItemFilters:_itemFilters];
  [itemSerializer setPathMapper:_pathMapper];

  PlaylistSerializer* playlistSerializer = [[PlaylistSerializer alloc] initWithEntityRepository:_entityRepository];
  [playlistSerializer setDelegate:self];
  [playlistSerializer setPlaylistFilters:_playlistFilters];
  [playlistSerializer setFlattenFolders:NO]; // TODO: configure

  LibrarySerializer* librarySerializer = [[LibrarySerializer alloc] init];
  [librarySerializer setPersistentID:@""]; // TODO: configure
  [librarySerializer setMusicLibraryDir:@""]; // TODO: configure

  OrderedDictionary* libraryDict = [librarySerializer serializeLibrary:library
                                                             withItems:[itemSerializer serializeItems:library.allMediaItems]
                                                          andPlaylists:[playlistSerializer serializePlaylists:library.allPlaylists]];

  return [self writeLibrary:libraryDict error:&error];
}

- (BOOL)writeLibrary:(OrderedDictionary*)libraryDict error:(NSError**)error {

  MLE_Log_Info(@"ExportManager [writeLibrary]");

  NSURL* outputDirectoryUrl = [UserDefaultsExportConfiguration.sharedConfig resolveOutputDirectoryBookmarkAndReturnError:error];
  if (outputDirectoryUrl == nil) {
    MLE_Log_Info(@"ExportManager [writeLibrary] unable to retrieve output directory - a directory must be selected to obtain write permission");
    return NO;
  }

  NSString* outputFileName = UserDefaultsExportConfiguration.sharedConfig.outputFileName;
  if (outputFileName == nil || outputFileName.length == 0) {
    outputFileName = @"Library.xml"; // fallback to default filename
    MLE_Log_Info(@"ExportManager [writeLibrary] output filename unspecified - falling back to default: %@", outputFileName);
  }

  NSURL* outputFileUrl = [outputDirectoryUrl URLByAppendingPathComponent:outputFileName];

  // write library
  MLE_Log_Info(@"ExportManager [writeLibrary] saving to: %@", outputFileUrl);
  [outputDirectoryUrl startAccessingSecurityScopedResource];
  BOOL writeSuccess = [libraryDict writeToURL:outputFileUrl error:error];
  [outputDirectoryUrl stopAccessingSecurityScopedResource];

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

  MLE_Log_Info(@"ExportManager [serializedItems] serializing items %lu/%lu", (unsigned long)serialized, total);

  if (_delegate != nil && [_delegate respondsToSelector:@selector(exportedItems:ofTotal:)]) {
    [_delegate exportedItems:serialized ofTotal:total];
  }
}

- (void)serializedPlaylists:(NSUInteger)serialized ofTotal:(NSUInteger)total {

  MLE_Log_Info(@"ExportManager [serializedPlaylists] serializing playlists %lu/%lu", serialized, total);

  if (_delegate != nil && [_delegate respondsToSelector:@selector(exportedPlaylists:ofTotal:)]) {
    [_delegate exportedPlaylists:serialized ofTotal:total];
  }
}

@end
