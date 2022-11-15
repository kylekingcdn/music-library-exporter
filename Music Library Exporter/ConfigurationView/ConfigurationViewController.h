//
//  ConfigurationViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Cocoa/Cocoa.h>

#import "Defines.h"
#import "ExportManagerDelegate.h"

@class UserDefaultsExportConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationViewController : NSViewController<ExportManagerDelegate>


extern NSErrorDomain const __MLE_ErrorDomain_ConfigurationView;

typedef NS_ENUM(NSInteger, ConfigurationViewErrorCode) {
  ConfigurationViewErrorUknown,
  ConfigurationViewErrorOutputDirectoryUnwritable,
};


#pragma mark - Initializers

- (instancetype)init;
- (instancetype)initWithExportConfiguration:(UserDefaultsExportConfiguration*)exportConfiguration;


#pragma mark - Accessors

- (id)firstResponderView;


#pragma mark - Mutators

- (void)updateFromConfiguration;

- (IBAction)setMediaFolderLocation:(id)sender;
- (IBAction)browseAndValidateOutputDirectory:(id)sender;
- (IBAction)setOutputFileName:(id)sender;

- (IBAction)setRemapRootDirectory:(id)sender;
- (IBAction)setRemapOriginalText:(id)sender;
- (IBAction)setRemapReplacementText:(id)sender;
- (IBAction)setRemapLocalhostPrefix:(id)sender;

- (IBAction)setFlattenPlaylistHierarchy:(id)sender;
- (IBAction)setIncludeInternalPlaylists:(id)sender;
- (IBAction)customizePlaylists:(id)sender;

- (IBAction)setScheduleEnabled:(id)sender;
- (IBAction)setScheduleInterval:(id)sender;
- (IBAction)incrementScheduleInterval:(id)sender;
- (IBAction)setScheduleSkipOnBattery:(id)sender;

- (IBAction)exportLibrary:(id)sender;

- (BOOL)validateOutputDirectory:(NSURL*)outputDirUrl error:(NSError**)error;
- (void)browseForOutputDirectoryWithCallback:(nullable void(^)(NSURL* _Nullable outputUrl))callback;
- (void)browseAndValidateOutputDirectoryWithCallback:(nullable void(^)(BOOL isValid))callback;

- (void)showAlertForError:(NSError*)error callback:(nullable void(^)(NSModalResponse response))callback;

@end

NS_ASSUME_NONNULL_END
