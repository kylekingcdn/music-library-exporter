//
//  MediaItemSorter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "MediaItemSorter.h"

#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>

#import "Logger.h"
#import "SorterDefines.h"
#import "Utils.h"

@interface MediaItemSorter()

- (instancetype)init;

- (nullable id)valueOfItem:(ITLibMediaItem*)item forProperty:(NSString*)property;
- (nullable id)preprocessValue:(nullable id)value forProperty:(NSString*)property;

- (NSComparisonResult)compareItem:(ITLibMediaItem*)item1 withItem:(ITLibMediaItem*)item2;
- (NSComparisonResult)compareProperty:(NSString*)property ofItem:(ITLibMediaItem*)item1 withItem:(ITLibMediaItem*)item2 order:(PlaylistSortOrderType)order;

- (NSComparisonResult)alphabeticallyCompareString:(NSString*)str1 withString:(NSString*)str2;

@end

@implementation MediaItemSorter {

  NSString* _sortProperty; // temporary until PlaylistSortColumnType is migrated to property strings

  NSArray<NSString*>* _sortPrefixes; // temp
}

#pragma mark - Initializers

- (instancetype)init {

  return [self initWithSortColumn:PlaylistSortColumnNull andSortOrder:PlaylistSortOrderNull];
}

- (instancetype)initWithSortColumn:(PlaylistSortColumnType)sortColumn andSortOrder:(PlaylistSortOrderType)sortOrder {

  if (self = [super init]) {

    _sortColumn = sortColumn;
    _sortOrder = sortOrder;

    _sortProperty = [Utils mediaItemPropertyForSortColumn:sortColumn]; // temp
    if (_sortProperty == nil) {
      _sortProperty = @"";
    }

    _sortPrefixes = @[ @"a", @"an", @"the", ]; // temp

    return self;
  }
  else {
    return nil;
  }
}

#pragma mark - Accessors

- (NSArray<ITLibMediaItem*>*)sortItems:(NSArray<ITLibMediaItem*>*)items {

  // don't sort if sort column is null
  if (_sortColumn == PlaylistSortColumnNull) {
    return items;
  }

  // default to ascending sort order
  if (_sortOrder == PlaylistSortOrderNull) {
    _sortOrder = PlaylistSortOrderAscending;
  }


  return [items sortedArrayUsingComparator:^NSComparisonResult(id item1, id item2) {
    return [self compareItem:item1 withItem:item2];
  }];
}

- (nullable id)valueOfItem:(ITLibMediaItem*)item forProperty:(NSString*)property {

  id itemValue;

  if ([[SorterDefines propertySubstitutions] objectForKey:property] != nil) {

    // if substitutions exist for the property, return the first non-empty value
    for (NSString* substituteProperty in [SorterDefines substitutionsForProperty:property]) {

      itemValue = [item valueForProperty:substituteProperty];

      // return first non-empty value
      if (itemValue != nil) {
        /* DEBUG
        if (substituteProperty != property) {
          MLE_Log_Info(@"MediaItemSorter [valueOfItem] using substitute %@ for property %@ ('%@ - %@') ('%@ -> %@')", substituteProperty, property, item.album.albumArtist, item.title, [item valueForProperty:property], [item valueForProperty:substituteProperty]);
        }
         */
        // re-assign property for correct pre-processing of the substituted property
        property = substituteProperty;
        break;
      }
    }
  }

  // directly return value for given property
  else {
    itemValue = [item valueForProperty:property];
  }

  // preprocess and return the value
  return [self preprocessValue:itemValue forProperty:property];
}

- (nullable id)preprocessValue:(nullable id)value forProperty:(NSString*)property {

  // trim sort prefixes
  if ([[SorterDefines sortPrefixedProperties] containsObject:property]) {

    NSString* valueStr = (NSString*)value;

    // don't process nil or empty values
    if (valueStr != nil && valueStr.length > 0) {

      for (NSString* sortPrefix in _sortPrefixes) {

        // only trim values that are longer than prefix (plus space)
        if (sortPrefix.length+1 < valueStr.length) {

          NSString* processedValue = [valueStr stringByReplacingOccurrencesOfString:[sortPrefix stringByAppendingString:@" "]
                                                                      withString:@""
                                                                         options:(NSCaseInsensitiveSearch)
                                                                           range:NSMakeRange(0,sortPrefix.length+1)];
          // sort prefix removed
          if ([processedValue isNotEqualTo:valueStr]) {
            value = processedValue;
            // break to prevent additional sort prefix occurences from being trimmed
            break;
          }
        }
      }
    }
  }

  return value;
}

- (NSComparisonResult)compareItem:(ITLibMediaItem*)item1 withItem:(ITLibMediaItem*)item2 {

  NSComparisonResult result = [self compareProperty:_sortProperty ofItem:item1 withItem:item2 order:_sortOrder];

  // values are identical, attempt to sort by fallback properties
  if (result == NSOrderedSame) {

    for (NSString* fallbackProperty in [SorterDefines fallbackPropertiesForProperty:_sortProperty]) {

      // use ascending order for fallback properties
      result = [self compareProperty:fallbackProperty ofItem:item1 withItem:item2 order:PlaylistSortOrderAscending];

      // use first result that is not equal
      if (result != NSOrderedSame) {
//        MLE_Log_Info(@"MediaItemSorter [compareItem] used fallback %@ for property %@ ('%@ - %@', '%@ - %@')", fallbackProperty, _sortProperty, item1.album.albumArtist, item1.title, item2.album.albumArtist, item2.title);
        break;
      }
    }
  }

  return result;
}

- (NSComparisonResult)compareProperty:(NSString*)property ofItem:(ITLibMediaItem*)item1 withItem:(ITLibMediaItem*)item2 order:(PlaylistSortOrderType)order {

  id item1Value = [self valueOfItem:item1 forProperty:property];
  id item2Value = [self valueOfItem:item2 forProperty:property];

  // handle nil values
  if (item1Value == nil || item2Value == nil) {
    if (item1Value == item2Value) {
      return NSOrderedSame;
    }
    else if (item1Value) {
      return NSOrderedAscending;
    }
    else {
      return NSOrderedDescending;
    }
  }

  NSComparisonResult result;
  if (item1Value && [item1Value isKindOfClass:[NSString class]]) {
    result = [self alphabeticallyCompareString:item1Value withString:item2Value];
  }
  else {
    result = [item1Value compare:item2Value];
  }

  if (order == PlaylistSortOrderAscending) {
    return result;
  }
  else {
    return -result;
  }
}

- (NSComparisonResult)alphabeticallyCompareString:(NSString*)str1 withString:(NSString*)str2 {

  // sort so that strings that begin with letters come before non-letter strings (begin with digit, special char, etc)
  BOOL str1LetterPrefix = [[NSCharacterSet letterCharacterSet] characterIsMember:[str1 characterAtIndex:0]];
  BOOL str2LetterPrefix = [[NSCharacterSet letterCharacterSet] characterIsMember:[str2 characterAtIndex:0]];
  if (str1LetterPrefix != str2LetterPrefix) {
    return str1LetterPrefix ? NSOrderedAscending : NSOrderedDescending;
  }

  return [str1 compare:str2 options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSNumericSearch)];
}

@end
