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

@end

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

static NSString *_Nonnull const ExportStateNames[] = {
  @"Stopped",
  @"Preparing",
  @"Generating tracks",
  @"Generating playlists",
  @"Generating library",
  @"Saving to disk",
  @"Finished",
  @"Error",
};

typedef NS_ENUM(NSUInteger, ExportDeferralReason) {
  ExportDeferralOnBatteryReason = 0,
  ExportDeferralMainAppOpenReason,
  ExportDeferralErrorReason,
  ExportDeferralUnknownReason,
  ExportNoDeferralReason,
};

static NSString *_Nonnull const ExportDeferralReasonNames[] = {
  @"Running on battery",
  @"Main app open",
  @"Error",
  @"Unknown",
  @"Not deferred",
};

typedef NS_ENUM(NSUInteger, PlaylistSortModeType) {
  PlaylistSortDefaultMode = 0,
  PlaylistSortCustomMode,
};

typedef NS_ENUM(NSUInteger, PlaylistSortOrderType) {
  PlaylistSortOrderAscending = 0,
  PlaylistSortOrderDescending,
  PlaylistSortOrderNull,
};

static NSString *_Nullable const PlaylistSortOrderNames[] = {
  @"Ascending",
  @"Descending",
  nil,
};

NS_ASSUME_NONNULL_END
