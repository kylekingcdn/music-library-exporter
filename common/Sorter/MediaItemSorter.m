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

  self = [super init];

  _sortColumn = PlaylistSortColumnNull;
  _sortOrder = PlaylistSortOrderNull;

  return self;
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

+ (NSComparisonResult)alphabeticallyCompareString:(NSString*)string1 withString:(NSString*)string2 {

  BOOL string1HasLetterPrefix = [[NSCharacterSet letterCharacterSet] characterIsMember:[string1 characterAtIndex:0]];
  BOOL string2HasLetterPrefix = [[NSCharacterSet letterCharacterSet] characterIsMember:[string2 characterAtIndex:0]];

  if (string1HasLetterPrefix && !string2HasLetterPrefix) {
    return NSOrderedAscending;
  }
  else if (!string1HasLetterPrefix && string2HasLetterPrefix) {
    return NSOrderedDescending;
  }
  else {
    return [string1 compare:string2 options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSNumericSearch)];
  }
}

@end
