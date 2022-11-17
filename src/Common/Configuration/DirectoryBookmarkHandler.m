//
//  DirectoryBookmarkHandler.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-15.
//

#import "DirectoryBookmarkHandler.h"

#import "Defines.h"
#import "Logger.h"

@implementation DirectoryBookmarkHandler {

  NSString* _defaultsKey;

  NSUserDefaults* _userDefaults;
}

#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithUserDefaultsKey:(NSString*)defaultsKey {

  if (self = [self init]) {

    _defaultsKey = defaultsKey;

    return self;
  }
  else {
    return nil;
  }
}

#pragma mark - Accessors

- (nullable NSData*)bookmarkDataFromDefaults {

  if (_defaultsKey == nil || _defaultsKey.length == 0) {
    return nil;
  }

  return [_userDefaults dataForKey:_defaultsKey];
}

- (nullable NSURL*)urlFromDefaultsAndReturnError:(NSError**)error {

  NSData* bookmarkData = [self bookmarkDataFromDefaults];

  // no bookmark has been saved yet
  if (bookmarkData == nil) {
    MLE_Log_Info(@"DirectoryBookmarkHandler [urlFromDefaults] bookmark is nil");
    return nil;
  }

  // resolve URL for bookmark data
  BOOL bookmarkDataIsStale;
  NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:error];

  // error resolving bookmark data
  if (bookmarkURL == nil) {
    if (error) {
      MLE_Log_Info(@"DirectoryBookmarkHandler [urlFromDefaults] error resolving output dir bookmark: %@", [*error localizedDescription]);
    }
    return nil;
  }

  // bookmark data is stale, regenerate and save bookmark data
  if (bookmarkDataIsStale) {
    MLE_Log_Info(@"DirectoryBookmarkHandler [urlFromDefaults] bookmark is stale, saving new bookmark");
    [self saveURLToDefaults:bookmarkURL];
  }

  MLE_Log_Info(@"DirectoryBookmarkHandler [urlFromDefaults] bookmarked directory: %@", bookmarkURL.path);

  return bookmarkURL;
}

- (nullable NSURL*)urlFromDefaultsWithFilename:(NSString*)filename andReturnError:(NSError**)error {

  if (filename.length == 0) {
    return nil;
  }

  NSURL* directoryURL = [self urlFromDefaultsAndReturnError:error];
  if (directoryURL == nil) {
    return nil;
  }
  return [directoryURL URLByAppendingPathComponent:filename];
}

#pragma mark - Mutators

- (void)saveBookmarkDataToDefaults:(nullable NSData*)bookmarkData {

  if (_defaultsKey == nil || _defaultsKey.length == 0) {
    return;
  }
  MLE_Log_Info(@"DirectoryBookmarkHandler [saveBookmarkDataToDefaults]");

  // data is nil, remove the value from user defaults
  [_userDefaults setValue:bookmarkData forKey:_defaultsKey];
}

- (BOOL)saveURLToDefaults:(nullable NSURL*)url {

  if (_defaultsKey == nil || _defaultsKey.length == 0) {
    return YES;
  }
  MLE_Log_Info(@"DirectoryBookmarkHandler [saveURLToDefaults: %@]", url);

  // URL is nil, remove the value from user defaults
  if (url == nil) {
      [_userDefaults removeObjectForKey:_defaultsKey];
      return YES;
  }

  /* ---- scoped security access started ---- */
  [url startAccessingSecurityScopedResource];

  // create new bookmark
  NSError* bookmarkCreateError;
  NSData* bookmarkData = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&bookmarkCreateError];

  [url stopAccessingSecurityScopedResource];
  /* ---- scoped security access stopped ---- */

  // error generating bookmark
  if (bookmarkCreateError) {
    MLE_Log_Info(@"DirectoryBookmarkHandler [saveURLToDefaults] error generating bookmark data: %@", bookmarkCreateError.localizedDescription);
    return NO;
  }

  // save bookmark data to user defaults
  if (bookmarkData != nil) {
    [self saveBookmarkDataToDefaults:bookmarkData];
  }
  // error generating bookmark
  else {
    MLE_Log_Info(@"DirectoryBookmarkHandler [saveURLToDefaults] error generating bookmark data: %@", bookmarkCreateError.localizedDescription);
  }

  return bookmarkData != nil;
}

@end
