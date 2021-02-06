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


#pragma mark - Properties -

@property ITLibrary* library;
@property ExportConfiguration* configuration;


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (NSSet<NSNumber*>*)getIncludedPlaylistKinds;

- (NSArray<ITLibMediaItem*>*)getIncludedTracks;
- (NSArray<ITLibPlaylist*>*)getIncludedPlaylists;


@end

NS_ASSUME_NONNULL_END
