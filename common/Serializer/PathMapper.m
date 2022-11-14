//
//  PathMapper.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "PathMapper.h"

@implementation PathMapper

- (instancetype)init {

  if (self = [super init]) {

    _addLocalhostPrefix = YES;
    return self;
  }
  else {
    return nil;
  }
}

- (NSString*)processPath:(NSString*)path {

  if (_searchString != nil && _replaceString != nil) {
    return [path stringByReplacingOccurrencesOfString:_searchString withString:_replaceString];
  }
  else {
    return path;
  }
}

- (NSURL*)mapURLFromPath:(NSString*)path {

  NSString* mappedPath = [self processPath:path];

  return [NSURL fileURLWithPath:mappedPath relativeToURL:[NSURL fileURLWithPath:@"/"]];
}

- (NSString*)mapPath:(NSURL*)pathURL {

  NSURL* mappedURL = [self mapURLFromPath:pathURL.path];
  NSString* mappedString = [mappedURL absoluteString];

  if (_addLocalhostPrefix) {
    mappedString = [mappedString stringByReplacingOccurrencesOfString:@"file:///" withString:@"file://localhost/"];
  }

  return mappedString;
}

@end
