//
//  MediaItemSorter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import "MediaItemSorter.h"

#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibMediaItem.h>

#import "Logger.h"
#import "SorterDefines.h"
#import "Utils.h"

@interface MediaItemSorter()

- (nullable id)valueOfItem:(ITLibMediaItem*)item forProperty:(NSString*)property;
- (nullable id)preprocessValue:(nullable id)value forProperty:(NSString*)property;

+ (NSComparisonResult)alphabeticallyCompareString:(NSString*)str1 withString:(NSString*)str2;

@end

@implementation MediaItemSorter {

  NSArray<NSString*>* _sortPrefixes;
}

#pragma mark - Initializers

- (instancetype)init {

  return [self initWithSortColumn:PlaylistSortColumnNull andSortOrder:PlaylistSortOrderNull];
}

- (instancetype)initWithSortColumn:(PlaylistSortColumnType)sortColumn andSortOrder:(PlaylistSortOrderType)sortOrder {

  if (self = [super init]) {

    _sortColumn = sortColumn;
    _sortOrder = sortOrder;

    _sortPrefixes = @[ @"a", @"an", @"the", ]; // temp

    return self;
  }
  else {
    return nil;
  }
}

#pragma mark - Accessors

- (nullable id)valueOfItem:(ITLibMediaItem*)item forProperty:(NSString*)property {

  return [self preprocessValue:[item valueForProperty:property] forProperty:property];

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

- (NSArray<ITLibMediaItem*>*)sortItems:(NSArray<ITLibMediaItem*>*)items {

  // don't sort if sort column is null
  if (_sortColumn == PlaylistSortColumnNull) {
    return items;
  }

  // default to ascending sort order
  if (_sortOrder == PlaylistSortOrderNull) {
    _sortOrder = PlaylistSortOrderAscending;
  }

  NSString* itemProperty = [Utils mediaItemPropertyForSortColumn:_sortColumn];

  return [items sortedArrayUsingComparator:^NSComparisonResult(id item1, id item2) {

    id item1Value = [self valueOfItem:item1 forProperty:itemProperty];
    id item2Value = [self valueOfItem:item2 forProperty:itemProperty];

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
      // TODO: handle title/sortTitle artist/sortArtist albumArtist/sortAlbumArtist
      result = [MediaItemSorter alphabeticallyCompareString:item1Value withString:item2Value];
    }
    else {
      result = [item1Value compare:item2Value];
    }

    if (_sortOrder == PlaylistSortOrderAscending) {
      return result;
    }
    else {
      return -result;
    }
  }];
}

+ (NSComparisonResult)alphabeticallyCompareString:(NSString*)str1 withString:(NSString*)str2 {

  // sort so that strings that begin with letters come before non-letter strings (begin with digit, special char, etc)
  BOOL str1LetterPrefix = [[NSCharacterSet letterCharacterSet] characterIsMember:[str1 characterAtIndex:0]];
  BOOL str2LetterPrefix = [[NSCharacterSet letterCharacterSet] characterIsMember:[str2 characterAtIndex:0]];
  if (str1LetterPrefix != str2LetterPrefix) {
    return str1LetterPrefix ? NSOrderedAscending : NSOrderedDescending;
  }

  return [str1 compare:str2 options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSNumericSearch)];
}

@end
