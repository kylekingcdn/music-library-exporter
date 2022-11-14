//
//  PathMapper.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PathMapper : NSObject

@property (copy,nullable) NSString* searchString;
@property (copy,nullable) NSString* replaceString;

- (instancetype)init;
- (NSString*)mapPath:(NSURL*)path;

@end

NS_ASSUME_NONNULL_END
