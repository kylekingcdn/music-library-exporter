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
#import "Utils.h"

@implementation MediaItemSorter

- (instancetype)init {

  return [self initWithSortColumn:PlaylistSortColumnNull andSortOrder:PlaylistSortOrderNull];
}

- (instancetype)initWithSortColumn:(PlaylistSortColumnType)sortColumn andSortOrder:(PlaylistSortOrderType)sortOrder {

  if (self = [super init]) {

    _sortColumn = sortColumn;
    _sortOrder = sortOrder;

    return self;
  }
  else {
    return nil;
  }
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

    id item1Value = [(ITLibMediaItem*)item1 valueForProperty:itemProperty];
    id item2Value = [(ITLibMediaItem*)item2 valueForProperty:itemProperty];

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
