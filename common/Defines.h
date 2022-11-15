//
//  Defines.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface Defines : NSObject

extern NSString* const __MLE__AppGroupIdentifier;
extern NSString* const __MLE__AppBundleIdentifier;
extern NSString* const __MLE__HelperBundleIdentifier;

typedef NS_ENUM(NSUInteger, ExportState) {
  ExportStopped = 0,
  ExportPreparing,
  ExportGeneratingTracks,
  ExportGeneratingPlaylists,
  ExportGeneratingLibrary,
  ExportWritingToDisk,
  ExportFinished,
  ExportError
};

typedef NS_ENUM(NSUInteger, ExportDeferralReason) {
  ExportDeferralOnBatteryReason = 0,
  ExportDeferralMainAppOpenReason,
  ExportDeferralErrorReason,
  ExportDeferralUnknownReason,
  ExportNoDeferralReason,
};

typedef NS_ENUM(NSUInteger, PlaylistSortModeType) {
  PlaylistSortDefaultMode = 0,
  PlaylistSortCustomMode,
};

typedef NS_ENUM(NSUInteger, PlaylistSortColumnType) {
  PlaylistSortColumnTitle = 0,
  PlaylistSortColumnArtist,
  PlaylistSortColumnAlbumArtist,
  PlaylistSortColumnDateAdded,
  PlaylistSortColumnNull,
};

typedef NS_ENUM(NSUInteger, PlaylistSortOrderType) {
  PlaylistSortOrderAscending = 0,
  PlaylistSortOrderDescending,
  PlaylistSortOrderNull,
};

@end

NS_ASSUME_NONNULL_END
