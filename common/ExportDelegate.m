//
//  ExportDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import "ExportDelegate.h"

#import <iTunesLibrary/ITLibrary.h>

#import "Defines.h"
#import "UserDefaultsExportConfiguration.h"
#import "LibrarySerializer.h"
#import "OrderedDictionary.h"


@implementation ExportDelegate {

  NSUserDefaults* _userDefaults;

  NSDate* _lastExportedAt;

  LibrarySerializer* _librarySerializer;
  ITLibrary* _itLibrary;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  _state = ExportStopped;
  
  _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  _librarySerializer = [[LibrarySerializer alloc] init];

  [self loadPropertiesFromUserDefaults];

  return self;
}

- (instancetype)initWithConfiguration:(UserDefaultsExportConfiguration*)config {

  self = [self init];

  [self setConfiguration:config];

  return self;
}


#pragma mark - Accessors -

- (NSDate*)lastExportedAt {

  return _lastExportedAt;
}

- (nullable NSArray<ITLibMediaItem*>*)includedTracks {

  if (!_librarySerializer) {
    return nil;
  }

  return _librarySerializer.includedTracks;
}

- (nullable NSArray<ITLibPlaylist*>*)includedPlaylists {

  if (!_librarySerializer) {
    return nil;
  }

  return _librarySerializer.includedPlaylists;
}

- (void)dumpProperties {

  NSLog(@"ExportDelegate [dumpProperties]");

  NSLog(@"  LastExportedAt:                  '%@'", _lastExportedAt.description);
}


#pragma mark - Mutators -

- (void)updateState:(ExportState)state {

  _state = state;

  if (_stateCallback) {
    _stateCallback(_state);
  }
}

- (void)loadPropertiesFromUserDefaults {

  NSLog(@"ExportDelegate [loadPropertiesFromUserDefaults]");

  _lastExportedAt = [_userDefaults valueForKey:@"LastExportedAt"];
}

- (void)setLastExportedAt:(nullable NSDate*)timestamp {

  NSLog(@"ExportDelegate [setLastExportedAt %@]", timestamp.description);

  _lastExportedAt = timestamp;

  [_userDefaults setValue:_lastExportedAt forKey:@"LastExportedAt"];
}

- (BOOL)prepareForExport {

  NSLog(@"ExportDelegate [prepareForExport]");

  [self updateState:ExportPreparing];

  // set configuration
  if (!_configuration.isOutputDirectoryValid) {
    NSLog(@"ExportDelegate [prepareForExport] error - invalid output directory url");
    [self updateState:ExportError];
    return NO;
  }
  if (!_configuration.isOutputFileNameValid) {
    NSLog(@"ExportDelegate [prepareForExport] error - invalid output filename");
    [self updateState:ExportError];
    return NO;
  }
  [_librarySerializer setConfiguration:_configuration];

  // init ITLibrary instance
  NSError *initLibraryError = nil;
  _itLibrary = [ITLibrary libraryWithAPIVersion:@"1.1" error:&initLibraryError];
  if (!_itLibrary) {
    NSLog(@"ExportDelegate [prepareForExport]  error - failed to init ITLibrary. error: %@", initLibraryError.localizedDescription);
    [self updateState:ExportError];
    return NO;
  }
  [_librarySerializer setLibrary:_itLibrary];

  [_librarySerializer initSerializeMembers];

  [_librarySerializer determineIncludedPlaylists];
  [_librarySerializer determineIncludedTracks];

  return YES;
}

- (void)exportLibrary {

  NSLog(@"ExportDelegate [exportLibrary]");

  // serialize tracks
  NSLog(@"ExportDelegate [exportLibrary] serializing tracks");
  [self updateState:ExportGeneratingTracks];
  OrderedDictionary* tracks = [_librarySerializer serializeIncludedTracksWithProgressCallback:_progressCallback];

  // serialize playlists
  NSLog(@"ExportDelegate [exportLibrary] serializing playlists");
  [self updateState:ExportGeneratingPlaylists];
  NSArray<OrderedDictionary*>* playlists = [_librarySerializer serializeIncludedPlaylists];

  // serialize library
  NSLog(@"ExportDelegate [exportLibrary] serializing library");
  OrderedDictionary* library = [_librarySerializer serializeLibraryforTracks:tracks andPlaylists:playlists];

  // write library
  NSLog(@"ExportDelegate [exportLibrary] writing library");
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

  NSLog(@"ExportDelegate [writeDictionary]");

  NSURL* outputDirectoryUrl = _configuration.resolveAndAutoRenewOutputDirectoryUrl;
  if (!outputDirectoryUrl) {
    NSLog(@"ExportDelegate [writeDictionary] unable to retrieve output directory - a directory must be selected to obtain write permission");
    return NO;
  }

  // write library
  NSLog(@"ExportDelegate [writeDictionary] saving to: %@", _configuration.outputFileUrl);
  [outputDirectoryUrl startAccessingSecurityScopedResource];
  BOOL writeSuccess = [libraryDict writeToURL:_configuration.outputFileUrl atomically:YES];
  [outputDirectoryUrl stopAccessingSecurityScopedResource];

  if (!writeSuccess) {
    NSLog(@"ExportDelegate [writeDictionary] error writing dictionary");
    return NO;
  }

  return YES;
}

@end

