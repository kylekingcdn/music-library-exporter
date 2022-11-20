//
//  SorterDefines.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-17.
//

#import "SorterDefines.h"

#import <iTunesLibrary/ITLibMediaItem.h>

static SorterDefines* _sharedDefines;

@interface SorterDefines ()

@property NSArray<NSString*>* allProperties;
@property NSSet<NSString*>* allPropertiesSet;

@property NSDictionary* propertyNames;
@property NSDictionary* propertySubstitutions;

@property NSDictionary* fallbackSortProperties;
@property NSArray<NSString*>* defaultFallbackSortProperties;

@property NSDictionary* migratedProperties;

- (void)populateAllProperties;

- (void)populatePropertyNames;
- (void)populatePropertySubstitutions;

- (void)populateFallbackSortProperties;
- (void)populateDefaultFallbackSortProperties;

- (void)populateMigratedProperties;

@end


@implementation SorterDefines

#pragma mark - Inintializers

- (instancetype)init {

  if (self = [super init]) {

    NSAssert((_sharedDefines == nil), @"SorterDefines _sharedDefines has already been initialized");

    [self populateAllProperties];

    [self populatePropertyNames];
    [self populatePropertySubstitutions];

    [self populateFallbackSortProperties];
    [self populateDefaultFallbackSortProperties];

    [self populateMigratedProperties];

    return self;
  }
  else {
    return nil;
  }
}

#pragma mark - Accessors

+ (NSArray<NSString*>*)allProperties {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.allProperties;
}

+ (NSSet<NSString*>*)allPropertiesSet {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.allPropertiesSet;
}

+ (NSDictionary*)propertyNames {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.propertyNames;
}

+ (NSDictionary*)propertySubstitutions {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.propertySubstitutions;
}

+ (NSDictionary*)fallbackSortProperties {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.fallbackSortProperties;
}

+ (NSArray<NSString*>*)defaultFallbackSortProperties {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.defaultFallbackSortProperties;
}

+ (NSDictionary*)migratedProperties {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.migratedProperties;
}

+ (nullable NSString*)nameForProperty:(NSString*)property {

  return [[SorterDefines propertyNames] valueForKey:property];
}

+ (NSArray<NSString*>*)substitutionsForProperty:(NSString*)property {

  if ([[SorterDefines propertySubstitutions] objectForKey:property] != nil) {
    return [[_sharedDefines propertySubstitutions] valueForKey:property];
  }
  else {
    return [NSArray array];
  }
}

+ (NSArray<NSString*>*)fallbackPropertiesForProperty:(NSString*)property {

  if ([[SorterDefines fallbackSortProperties] objectForKey:property] != nil) {
    return [[_sharedDefines fallbackSortProperties] valueForKey:property];
  }
  else {
    return [_sharedDefines defaultFallbackSortProperties];
  }
}


#pragma mark - Mutators

- (void)populateAllProperties {

  _allProperties = @[
    ITLibMediaItemPropertyAlbumTitle,
    ITLibMediaItemPropertyAlbumArtist,
    ITLibMediaItemPropertyAlbumRating,
    ITLibMediaItemPropertyAlbumDiscNumber,
    ITLibMediaItemPropertyArtistName,
    ITLibMediaItemPropertyBitRate,
    ITLibMediaItemPropertyBeatsPerMinute,
    ITLibMediaItemPropertyCategory,
    ITLibMediaItemPropertyComments,
    ITLibMediaItemPropertyComposer,
    ITLibMediaItemPropertyAddedDate,
    ITLibMediaItemPropertyModifiedDate,
    ITLibMediaItemPropertyDescription,
    ITLibMediaItemPropertyGenre,
    ITLibMediaItemPropertyGrouping,
    ITLibMediaItemPropertyKind,
    ITLibMediaItemPropertyTitle,
    ITLibMediaItemPropertyPlayCount,
    ITLibMediaItemPropertyLastPlayDate,
    ITLibMediaItemPropertyPlayStatus,
    ITLibMediaItemPropertyMovementName,
    ITLibMediaItemPropertyMovementNumber,
    ITLibMediaItemPropertyRating,
    ITLibMediaItemPropertyReleaseDate,
    ITLibMediaItemPropertySampleRate,
    ITLibMediaItemPropertySize,
    ITLibMediaItemPropertyUserSkipCount,
    ITLibMediaItemPropertySkipDate,
    ITLibMediaItemPropertyTotalTime,
    ITLibMediaItemPropertyTrackNumber,
    ITLibMediaItemPropertyWork,
    ITLibMediaItemPropertyYear,
  ];

  _allPropertiesSet = [NSSet setWithArray:_allProperties];
}

- (void)populatePropertyNames {

  _propertyNames = @{
    ITLibMediaItemPropertyAlbumTitle: @"Album",
    ITLibMediaItemPropertyAlbumArtist: @"Album Artist",
    ITLibMediaItemPropertyAlbumRating: @"Album Rating",
    ITLibMediaItemPropertyAlbumDiscNumber: @"Disc Number",
    ITLibMediaItemPropertyArtistName: @"Artist",
    ITLibMediaItemPropertyBitRate: @"Bit Rate",
    ITLibMediaItemPropertyBeatsPerMinute: @"Beats Per Minute",
    ITLibMediaItemPropertyCategory: @"Category",
    ITLibMediaItemPropertyComments: @"Comments",
    ITLibMediaItemPropertyComposer: @"Composer",
    ITLibMediaItemPropertyAddedDate: @"Date Added",
    ITLibMediaItemPropertyModifiedDate: @"Date Modified",
    ITLibMediaItemPropertyDescription: @"Description",
    ITLibMediaItemPropertyGenre: @"Genre",
    ITLibMediaItemPropertyGrouping: @"Grouping",
    ITLibMediaItemPropertyKind: @"Kind",
    ITLibMediaItemPropertyTitle: @"Title",
    ITLibMediaItemPropertyPlayCount: @"Plays",
    ITLibMediaItemPropertyLastPlayDate: @"Last Played",
    ITLibMediaItemPropertyPlayStatus: @"PlayStatus",
    ITLibMediaItemPropertyMovementName: @"Movement Name",
    ITLibMediaItemPropertyMovementNumber: @"Movement Number",
    ITLibMediaItemPropertyRating: @"Rating",
    ITLibMediaItemPropertyReleaseDate: @"Release Date",
    ITLibMediaItemPropertySampleRate: @"Sample Rate",
    ITLibMediaItemPropertySize: @"Size",
    ITLibMediaItemPropertyUserSkipCount: @"Skips",
    ITLibMediaItemPropertySkipDate: @"Last Skipped",
    ITLibMediaItemPropertyTotalTime: @"Time",
    ITLibMediaItemPropertyTrackNumber: @"Track Number",
    ITLibMediaItemPropertyWork: @"Work",
    ITLibMediaItemPropertyYear: @"Year",
  };
}

- (void)populatePropertySubstitutions {

  _propertySubstitutions = @{
    ITLibMediaItemPropertyTitle: @[
      ITLibMediaItemPropertySortTitle,
      ITLibMediaItemPropertyTitle,
    ],
    ITLibMediaItemPropertyAlbumTitle: @[
      ITLibMediaItemPropertySortAlbumTitle,
      ITLibMediaItemPropertyAlbumTitle,
    ],
    ITLibMediaItemPropertyAlbumArtist: @[
      ITLibMediaItemPropertySortAlbumArtist,
      ITLibMediaItemPropertyAlbumArtist,
      ITLibMediaItemPropertySortArtistName,
      ITLibMediaItemPropertyArtistName,
    ],
    ITLibMediaItemPropertyArtistName: @[
      ITLibMediaItemPropertySortArtistName,
      ITLibMediaItemPropertyArtistName,
      ITLibMediaItemPropertySortAlbumArtist,
      ITLibMediaItemPropertyAlbumArtist,
    ],
    ITLibMediaItemPropertyComposer: @[
      ITLibMediaItemPropertySortComposer,
      ITLibMediaItemPropertyComposer,
    ],
  };
}

- (void)populateFallbackSortProperties {

  _fallbackSortProperties = @{
    ITLibMediaItemPropertyAlbumTitle: @[
      ITLibMediaItemPropertyAlbumArtist,
      ITLibMediaItemPropertyAlbumDiscNumber,
      ITLibMediaItemPropertyTrackNumber,
      ITLibMediaItemPropertyTitle,
      ITLibMediaItemPropertyYear,
      ITLibMediaItemPropertyAddedDate
    ],
  };
}

- (void)populateDefaultFallbackSortProperties {

  _defaultFallbackSortProperties = @[
      ITLibMediaItemPropertyAlbumArtist,
      ITLibMediaItemPropertyAlbumTitle,
      ITLibMediaItemPropertyAlbumDiscNumber,
      ITLibMediaItemPropertyTrackNumber,
      ITLibMediaItemPropertyTitle,
      ITLibMediaItemPropertyYear,
      ITLibMediaItemPropertyAddedDate,
  ];
}

- (void)populateMigratedProperties {

  _migratedProperties = @{
    @"Title": ITLibMediaItemPropertyTitle,
    @"Artist": ITLibMediaItemPropertyArtistName,
    @"Album Artist": ITLibMediaItemPropertyAlbumArtist,
    @"Date Added": ITLibMediaItemPropertyAddedDate,
  };
}




@end
