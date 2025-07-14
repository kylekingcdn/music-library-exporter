//
//  PathMapper.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "PathMapper.h"

#import <OSLog/OSLog.h>

@implementation PathMapper

- (instancetype)init {

  if (self = [super init]) {

    _addLocalhostPrefix = NO;
    return self;
  }
  else {
    return nil;
  }
}

- (NSString*)processPath:(NSString*)path {
  if (path == nil) {
    os_log_fault(OS_LOG_DEFAULT, "[PathMapper processPath] was erroneously provided a null file path!");
    return nil;
  }
  
  if (_searchString != nil && _replaceString != nil) {
    return [path stringByReplacingOccurrencesOfString:_searchString withString:_replaceString];
  }
  else {
    return path;
  }
}

- (NSURL*)mapURLFromPath:(NSString*)path {
  if (path == nil) {
    os_log_fault(OS_LOG_DEFAULT, "[PathMapper mapURLFromPath] was erroneously provided a null file path!");
    return nil;
  }

  NSString* mappedPath = [self processPath:path];
  os_log_debug(OS_LOG_DEFAULT, "Mapped item path from: '%{public}@' to '%{public}@'", path, mappedPath);

  NSURL* mappedUrl = [NSURL fileURLWithPath:mappedPath relativeToURL:[NSURL fileURLWithPath:@"/"]];

  return mappedUrl;
}

- (NSString*)mapPath:(NSURL*)pathURL {
  if (pathURL == nil) {
    os_log_fault(OS_LOG_DEFAULT, "[PathMapper mapPath] was erroneously provided a null path URL!");
    return nil;
  }

  os_log_debug(OS_LOG_DEFAULT, "Mapping item path from URL: '%{public}@'", pathURL);

  NSURL* mappedURL = [self mapURLFromPath:pathURL.path];
  NSString* mappedString = [mappedURL absoluteString];

  if (_addLocalhostPrefix) {
    mappedString = [mappedString stringByReplacingOccurrencesOfString:@"file:///" withString:@"file://localhost/"];
    os_log_debug(OS_LOG_DEFAULT, "Injected localhost prefix into path: %{public}@", pathURL);
  }
  else {
    os_log_debug(OS_LOG_DEFAULT, "Mapped path from '%{public}@' to '%{public}@'", pathURL, mappedString);
  }

  return mappedString;
}

@end
