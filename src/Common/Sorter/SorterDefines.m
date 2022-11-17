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

@property NSDictionary* propertyNames;
@property NSDictionary* propertySubstitutions;

@property NSArray<NSString*>* sortVariantProperties;
@property NSArray<NSString*>* sortPrefixedProperties;

@property NSDictionary* fallbackSortProperties;
@property NSArray<NSString*>* defaultFallbackSortProperties;

- (void)populateAllProperties;

- (void)populatePropertyNames;
- (void)populatePropertySubstitutions;

- (void)populateSortVariantProperties;
- (void)populateSortPrefixedProperties;

- (void)populateFallbackSortProperties;
- (void)populateDefaultFallbackSortProperties;

@end


@implementation SorterDefines

#pragma mark - Inintializers

- (instancetype)init {

  if (self = [super init]) {

    NSAssert((_sharedDefines == nil), @"SorterDefines _sharedDefines has already been initialized");

    [self populateAllProperties];

    [self populatePropertyNames];
    [self populatePropertySubstitutions];

    [self populateSortVariantProperties];
    [self populateSortPrefixedProperties];

    [self populateFallbackSortProperties];
    [self populateDefaultFallbackSortProperties];


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

+ (NSArray<NSString*>*)sortVariantProperties {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.sortVariantProperties;
}

+ (NSArray<NSString*>*)sortPrefixedProperties {

  if (_sharedDefines == nil) {
    _sharedDefines = [[SorterDefines alloc] init];
  }

  return _sharedDefines.sortPrefixedProperties;
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

+ (nullable NSString*)nameForProperty:(NSString*)property {

  return [[SorterDefines propertyNames] valueForKey:property];
}

+ (NSArray<NSString*>*)substitutionsForProperty:(NSString*)property {

  if ([[SorterDefines propertySubstitutions] doesContain:property]) {
    return [[_sharedDefines propertySubstitutions] valueForKey:property];
  }
  else {
    return [NSArray array];
  }
}

+ (NSArray<NSString*>*)fallbackPropertiesForProperty:(NSString*)property {

  if ([[SorterDefines fallbackSortProperties] doesContain:property]) {
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
    ITLibMediaItemPropertyFileSize,
    ITLibMediaItemPropertyUserSkipCount,
    ITLibMediaItemPropertySkipDate,
    ITLibMediaItemPropertyTotalTime,
    ITLibMediaItemPropertyTrackNumber,
    ITLibMediaItemPropertyLocationType,
    ITLibMediaItemPropertyWork,
    ITLibMediaItemPropertyYear,
    ITLibMediaItemPropertyMediaKind,
    ITLibMediaItemPropertyLocation,
  ];
}

- (void)populatePropertyNames {

  _propertyNames = @{
    ITLibMediaItemPropertyAlbumTitle: @"Album",
    ITLibMediaItemPropertyAlbumArtist: @"Album Artist",
    ITLibMediaItemPropertyAlbumRating: @"Album Rating",
    ITLibMediaItemPropertyAlbumDiscNumber: @"Disc Number",
    ITLibMediaItemPropertyArtistName: @"Artist",
    ITLibMediaItemPropertyBitRate: @"Bit Rate",
    ITLibMediaItemPropertyBeatsPerMinute: @"BPM",
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
    ITLibMediaItemPropertyFileSize: @"File Size",
    ITLibMediaItemPropertyUserSkipCount: @"Skips",
    ITLibMediaItemPropertySkipDate: @"Last Skipped",
    ITLibMediaItemPropertyTotalTime: @"Time",
    ITLibMediaItemPropertyTrackNumber: @"Track Number",
    ITLibMediaItemPropertyLocationType: @"Location Type",
    ITLibMediaItemPropertyWork: @"Work",
    ITLibMediaItemPropertyYear: @"Year",
    ITLibMediaItemPropertyMediaKind: @"Media Kind",
    ITLibMediaItemPropertyLocation: @"Location",
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

- (void)populateSortVariantProperties {

  _sortVariantProperties = @[
    ITLibMediaItemPropertySortAlbumTitle,
    ITLibMediaItemPropertySortAlbumArtist,
    ITLibMediaItemPropertySortArtistName,
    ITLibMediaItemPropertySortComposer,
    ITLibMediaItemPropertySortTitle,
  ];
}

- (void)populateSortPrefixedProperties {

  _sortPrefixedProperties = @[
    ITLibMediaItemPropertyTitle,
    ITLibMediaItemPropertyArtistName,
    ITLibMediaItemPropertyAlbumArtist,
    ITLibMediaItemPropertyAlbumTitle,
    ITLibMediaItemPropertyComposer,
  ];
}

- (void)populateFallbackSortProperties {

  _fallbackSortProperties = @{
    ITLibMediaItemPropertyAlbumTitle: @[
      ITLibMediaItemPropertyAlbumArtist,
      ITLibMediaItemPropertyAlbumDiscNumber,
      ITLibMediaItemPropertyTrackNumber,
      ITLibMediaItemPropertyAddedDate
    ],
  };
}

- (void)populateDefaultFallbackSortProperties {

  _defaultFallbackSortProperties = @[
      ITLibMediaItemPropertyAlbumArtist,
      ITLibMediaItemPropertyArtistName,
      ITLibMediaItemPropertyAlbumDiscNumber,
      ITLibMediaItemPropertyArtistName,
      ITLibMediaItemPropertyTrackNumber,
      ITLibMediaItemPropertyYear,
      ITLibMediaItemPropertyAddedDate,
  ];
}



@end