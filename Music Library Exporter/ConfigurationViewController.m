//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import <iTunesLibrary/ITLibrary.h>

#import "Defines.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ExportScheduleDelegate.h"


@interface ConfigurationViewController ()

@property (weak) IBOutlet NSTextField *libraryPathTextField;
@property (weak) IBOutlet NSTextField *outputDirectoryTextField;
@property (weak) IBOutlet NSButton *outputDirectoryBrowseButton;
@property (weak) IBOutlet NSTextField *outputFileNameTextField;

@property (weak) IBOutlet NSButton *remapRootDirectoryCheckBox;
@property (weak) IBOutlet NSTextField *remapOriginalDirectoryTextField;
@property (weak) IBOutlet NSTextField *remapMappedDirectoryTextField;

@property (weak) IBOutlet NSButton *flattenPlaylistsCheckBox;
@property (weak) IBOutlet NSButton *includeInternalPlaylistsCheckBox;

@property (weak) IBOutlet NSButton *scheduleEnabledCheckBox;
@property (weak) IBOutlet NSTextField *scheduleIntervalTextField;
@property (weak) IBOutlet NSStepper *scheduleIntervalStepper;

@property (weak) IBOutlet NSButton *exportLibraryButton;

@end


@implementation ConfigurationViewController


#pragma mark - Initializers -

- (instancetype)init {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];

  _exportDelegate = [[ExportDelegate alloc] init];
  _scheduleDelegate = [[ExportScheduleDelegate alloc] init];

  _librarySerializer = [[LibrarySerializer alloc] init];
  
  return self;
}


#pragma mark - Accessors -


#pragma mark - Mutators -

- (void)viewDidLoad {

  [super viewDidLoad];

  NSLog(@"[viewDidLoad] isSchedulerRegisteredWithSystem: %@", (_scheduleDelegate.isSchedulerRegisteredWithSystem ? @"YES" : @"NO"));

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  [self updateFromConfiguration];
}

- (void)updateFromConfiguration {

  [_libraryPathTextField setStringValue:_exportConfiguration.musicLibraryPath];
  [_outputDirectoryTextField setStringValue:_exportConfiguration.outputDirectoryPath];
  [_outputFileNameTextField setStringValue:_exportConfiguration.outputFileName];

  [_remapRootDirectoryCheckBox setState:(_exportConfiguration.remapRootDirectory ? NSControlStateValueOn : NSControlStateValueOff)];
  [_remapOriginalDirectoryTextField setStringValue:_exportConfiguration.remapRootDirectoryOriginalPath];
  [_remapMappedDirectoryTextField setStringValue:_exportConfiguration.remapRootDirectoryMappedPath];

  [_flattenPlaylistsCheckBox setState:(_exportConfiguration.flattenPlaylistHierarchy ? NSControlStateValueOn : NSControlStateValueOff)];
  [_includeInternalPlaylistsCheckBox setState:(_exportConfiguration.includeInternalPlaylists ? NSControlStateValueOn : NSControlStateValueOff)];
  //[_excludedPlaylistsTextField setStringValue:_exportConfiguration.excludedPlaylistPersistentIds];

  [_scheduleEnabledCheckBox setState:_scheduleDelegate.scheduleEnabled];
  [_scheduleIntervalTextField setIntegerValue:_scheduleDelegate.scheduleInterval];
  [_scheduleIntervalStepper setIntegerValue:_scheduleDelegate.scheduleInterval];
}

- (IBAction)setMediaFolderLocation:(id)sender {

  NSString* mediaFolder = [sender stringValue];

  [_exportConfiguration setMusicLibraryPath:mediaFolder];
}

- (IBAction)browseOutputDirectory:(id)sender {

  NSLog(@"[browseOutputDirectory]");

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setMessage:@"Select a location to save the generated library."];

  NSWindow* window = [[self view] window];

  [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {

    if (result == NSModalResponseOK) {

      NSURL* outputDirUrl = [openPanel URL];
      if (outputDirUrl) {

        [self->_exportConfiguration setOutputDirectoryUrl:outputDirUrl];
        [self->_outputDirectoryTextField setStringValue:outputDirUrl.path];
      }
    }
  }];
}

- (IBAction)setOutputFileName:(id)sender {

  NSString* outputFileName = [sender stringValue];

  [_exportConfiguration setOutputFileName:outputFileName];
}

- (IBAction)setRemapRootDirectory:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [_exportConfiguration setRemapRootDirectory:flag];
}

- (IBAction)setRemapOriginalText:(id)sender {

  NSString* remapOriginalText = [sender stringValue];

  [_exportConfiguration setRemapRootDirectoryOriginalPath:remapOriginalText];
}

- (IBAction)setRemapReplacementText:(id)sender {

  NSString* remapReplacementText = [sender stringValue];

  [_exportConfiguration setRemapRootDirectoryMappedPath:remapReplacementText];
}

- (IBAction)setFlattenPlaylistHierarchy:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [_exportConfiguration setFlattenPlaylistHierarchy:flag];
}

- (IBAction)setIncludeInternalPlaylists:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [_exportConfiguration setIncludeInternalPlaylists:flag];
}

- (IBAction)setScheduleEnabled:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [_scheduleDelegate setScheduleEnabled:flag];
}

- (IBAction)setScheduleInterval:(id)sender {

  NSInteger scheduleInterval = [sender integerValue];

  [_scheduleIntervalStepper setIntegerValue:scheduleInterval];
  [_scheduleDelegate setScheduleInterval:scheduleInterval];
}

- (IBAction)incrementScheduleInterval:(id)sender {

  NSInteger scheduleInterval = [sender integerValue];

  [_scheduleIntervalTextField setIntegerValue:scheduleInterval];
  [_scheduleDelegate setScheduleInterval:scheduleInterval];
}

- (IBAction)exportLibraryAction:(id)sender {

  BOOL exportSuccessful = [self exportLibrary];

  if (!exportSuccessful) {
    NSLog(@"[exportLibraryAction] library export has failed");
  }
}

- (BOOL)exportLibrary {

  // FIXME: use bookmarked output dir
  if (!_exportConfiguration.isOutputDirectoryValid) {
    NSLog(@"[exportLibrary] error - invalid output directory url");
    return NO;
  }

  if (!_exportConfiguration.isOutputFileNameValid) {
    NSLog(@"[exportLibrary] error - invalid output filename");
    return NO;
  }

  [_librarySerializer setConfiguration:_exportConfiguration];

  NSError *initLibraryError = nil;
  ITLibrary *itLibrary = [ITLibrary libraryWithAPIVersion:@"1.1" error:&initLibraryError];
  if (!itLibrary) {
    NSLog(@"[exportLibrary]  error - failed to init ITLibrary. error: %@", initLibraryError.localizedDescription);
    return NO;
  }

  // ensure url renewal status is current
  NSURL* outputDirectoryUrl = _exportConfiguration.resolveAndAutoRenewOutputDirectoryUrl;
  if (!outputDirectoryUrl) {
    NSLog(@"[exportLibrary] unable to retrieve output directory - a directory must be selected to obtain write permission");
    return NO;
  }
  NSLog(@"[exportLibrary] saving to: %@", outputDirectoryUrl);

  // serialize library
  NSLog(@"[exportLibrary] serializing library");
  [_librarySerializer serializeLibrary:itLibrary];

  // write library
  NSLog(@"[exportLibrary] writing library to file");
  [outputDirectoryUrl startAccessingSecurityScopedResource];
  BOOL writeSuccess = [_librarySerializer writeDictionary];
  [outputDirectoryUrl stopAccessingSecurityScopedResource];

  if (writeSuccess) {
    [_exportConfiguration setLastExportedAt:[NSDate date]];
    return YES;
  }
  else {
    return NO;
  }

}

@end
