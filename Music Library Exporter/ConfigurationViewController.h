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


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (BOOL)isScheduleRegisteredWithSystem;

- (NSString*)errorForSchedulerRegistration:(BOOL)registerFlag;


#pragma mark - Mutators -

- (void)updateFromConfiguration;

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


@end

NS_ASSUME_NONNULL_END
