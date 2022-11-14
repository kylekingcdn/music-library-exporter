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

    return self;
  }
  else {
    return nil;
  }
}

- (NSString*) mapPath:(NSString*)path {

  if (_searchString != nil && _replaceString != nil) {
    return [path stringByReplacingOccurrencesOfString:_searchString withString:_replaceString];
  }
  else {
    return path;
  }
}

@end
