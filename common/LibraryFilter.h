//
//  LibraryFilter.h
//  library-generator
//
//  Created by Kyle King on 2021-02-04.
//

#import <Foundation/Foundation.h>

@class ITLibrary;
@class ITLibMediaItem;
@class ITLibPlaylist;
@class ExportConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface LibraryFilter : NSObject


#pragma mark - Properties

@property BOOL filterExcludedPlaylistIds;


#pragma mark - Initializers

- (instancetype)initWithLibrary:(ITLibrary*)library;


#pragma mark - Accessors

- (NSArray<ITLibMediaItem*>*)getIncludedTracks;
- (NSArray<ITLibPlaylist*>*)getIncludedPlaylists;


#pragma mark - Mutators

- (void)initMediaItemFilters;
- (void)initPlaylistFilters;

@end

NS_ASSUME_NONNULL_END
