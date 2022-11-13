//
//  LibrarySerializer.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

@class ITLibrary;
@class OrderedDictionary;

NS_ASSUME_NONNULL_BEGIN

@interface LibrarySerializer : NSObject

- (instancetype) init;

@property (copy, nonnull) NSString* persistentID;
@property (copy, nonnull) NSString* musicLibraryDir;

- (OrderedDictionary*)serializeLibrary:(ITLibrary*)library withItems:(OrderedDictionary*)items andPlaylists:(NSArray<OrderedDictionary*>*)playlists;

@end

NS_ASSUME_NONNULL_END
