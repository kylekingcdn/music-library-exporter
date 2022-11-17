//
//  MediaEntityRepository.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

@class ITLibMediaEntity;

NS_ASSUME_NONNULL_BEGIN

@interface MediaEntityRepository : NSObject

- (instancetype)init;

- (nullable NSNumber*)getIDForEntity:(ITLibMediaEntity*)entity;

@end

NS_ASSUME_NONNULL_END
