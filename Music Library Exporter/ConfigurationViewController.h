//
//  ConfigurationViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Cocoa/Cocoa.h>

#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationViewController : NSViewController


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Mutators -

- (void)updateFromConfiguration;

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

- (IBAction)exportLibrary:(id)sender;

- (void)handleTrackExportProgress:(NSUInteger)currentTrack withTotal:(NSUInteger)trackCount;
- (void)handleStateChange:(ExportState)serializerState;

@end

NS_ASSUME_NONNULL_END
