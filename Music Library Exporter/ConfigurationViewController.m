//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

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

@property (weak) IBOutlet NSTextField *lastExportLabel;
@property (weak) IBOutlet NSButton *exportLibraryButton;

@end


@implementation ConfigurationViewController


#pragma mark - Initializers -

- (instancetype)init {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];

  _exportDelegate = [[ExportDelegate alloc] initWithConfiguration:_exportConfiguration];
  _scheduleDelegate = [[ExportScheduleDelegate alloc] initWithExportDelegate:_exportDelegate];

  [_exportConfiguration dumpProperties];
  [_exportDelegate dumpProperties];
  [_scheduleDelegate dumpProperties];
  
  return self;
}


#pragma mark - Accessors -


#pragma mark - Mutators -

- (void)viewDidLoad {

  [super viewDidLoad];

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

  if (_exportDelegate.lastExportedAt) {
    [_lastExportLabel setStringValue:[@"Last export: " stringByAppendingString:_exportDelegate.lastExportedAt.description]];
    [_lastExportLabel setHidden:NO];
  }
  else {
    [_lastExportLabel setStringValue:@""];
    [_lastExportLabel setHidden:YES];
  }
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

- (IBAction)exportLibrary:(id)sender {

  BOOL exportSuccessful = [_exportDelegate exportLibrary];

  if (!exportSuccessful) {
    NSLog(@"[exportLibrary] library export has failed");
  }
  else {
    if (_exportDelegate.lastExportedAt) {
      [_lastExportLabel setStringValue:[@"Last export: " stringByAppendingString:_exportDelegate.lastExportedAt.description]];
      [_lastExportLabel setHidden:NO];
    }
    else {
      [_lastExportLabel setStringValue:@""];
      [_lastExportLabel setHidden:YES];
    }
  }
}

@end
