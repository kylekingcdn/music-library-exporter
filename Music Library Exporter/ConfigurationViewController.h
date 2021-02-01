//
//  ConfigurationViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Cocoa/Cocoa.h>

#import "LibrarySerializer.h"

NS_ASSUME_NONNULL_BEGIN

@class UserDefaultsExportConfiguration;

@interface ConfigurationViewController : NSViewController {

  BOOL _scheduleEnabled;
  
  UserDefaultsExportConfiguration* _exportConfiguration;
  LibrarySerializer* _librarySerializer;
}

- (instancetype)init;

- (BOOL)isScheduleRegisteredWithSystem;
- (BOOL)registerSchedulerWithSystem:(BOOL)flag;

- (IBAction)setMediaFolderLocation:(id)sender;
- (IBAction)browseOutputDirectory:(id)sender;
- (IBAction)setOutputFileName:(id)sender;

- (IBAction)setRemapRootDirectory:(id)sender;
- (IBAction)setRemapOriginalText:(id)sender;
- (IBAction)setRemapReplacementText:(id)sender;

- (IBAction)setFlattenPlaylistHierarchy:(id)sender;
- (IBAction)setIncludeInternalPlaylists:(id)sender;

- (IBAction)setScheduleEnabled:(id)sender;
- (IBAction)setScheduleInterval:(id)sender;
- (IBAction)incrementScheduleInterval:(id)sender;

- (IBAction)exportLibraryAction:(id)sender;

- (BOOL)exportLibrary;
- (NSData*)fetchOutputDirectoryBookmarkData;
- (NSURL*)resolveAndAutoRenewOutputDirectoryUrl;
- (BOOL)saveBookmarkForOutputDirectoryUrl:(NSURL*)outputDirUrl;

- (NSString*)errorForSchedulerRegistration:(BOOL)registerFlag;

- (void)updateFromConfiguration;

@end

NS_ASSUME_NONNULL_END
