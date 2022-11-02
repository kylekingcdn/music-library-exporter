//
//  MediaEntityRepository.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "MediaEntityRepository.h"

#import <iTunesLibrary/ITLibMediaEntity.h>

@implementation MediaEntityRepository {

  NSUInteger _currentEntityID;

  NSMutableDictionary* _entityIDs;
}

- (instancetype)init {

  self = [super init];

  _currentEntityID = 1;
  _entityIDs = [NSMutableDictionary dictionary];

  return self;
}

- (nullable NSNumber*)getIDForEntity:(ITLibMediaEntity*)entity {

  if (entity == nil) {
    return nil;
  }

  NSNumber* entityID = [_entityIDs objectForKey:entity.persistentID];

  // not stored yet
  if (entityID == nil) {
    entityID = [NSNumber numberWithUnsignedInteger:++_currentEntityID];
    [_entityIDs setObject:entityID forKey:entity.persistentID];
  }

  return entityID;
}

@end
