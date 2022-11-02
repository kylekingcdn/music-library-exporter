//
//  PathMapper.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "PathMapper.h"

@implementation PathMapper

- (NSString*) mapPath:(NSString*)path {

  if (_searchString != nil && _replaceString != nil) {
    return [path stringByReplacingOccurrencesOfString:_searchString withString:_replaceString];
  }
  else {
    return path;
  }
}

@end
