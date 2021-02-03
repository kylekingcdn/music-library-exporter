//
//  LibraryParser.h
//  library-generator
//
//  Created by Kyle King on 2021-01-22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LibraryParser : NSObject


#pragma mark - Properties -

@property NSDictionary* libraryDictionary;


#pragma mark - Accessors -

- (NSArray<NSDictionary*>*) libraryTracks;
- (NSArray<NSDictionary*>*) libraryPlaylists;

- (NSDictionary*) libraryTracksPersistentIdDictionary;
- (NSDictionary*) libraryPlaylistsPersistentIdDictionary;


#pragma mark - Mutators -

- (void) setLibraryDictionaryWithPropertyList:(NSString * _Nonnull)plistFilePath;


@end

NS_ASSUME_NONNULL_END
