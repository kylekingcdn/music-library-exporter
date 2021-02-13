//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import "Utils.h"
#import "HelperDelegate.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"
#import "HourNumberFormatter.h"
#import "AppDelegate.h"

static void *MLEProgressObserverContext = &MLEProgressObserverContext;

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
@property (weak) IBOutlet NSButton *scheduleSkipOnBatteryCheckBox;

@property (weak) IBOutlet NSTextField *nextExportLabel;
@property (weak) IBOutlet NSTextField *lastExportLabel;

@property (weak) IBOutlet NSButton *exportLibraryButton;

@property (weak) IBOutlet NSVisualEffectView *progressView;
@property (weak) IBOutlet NSTextField *exportStateLabel;
@property (weak) IBOutlet NSProgressIndicator *exportProgressBar;

@end


@implementation ConfigurationViewController {

  HelperDelegate* _helperDelegate;

  ExportDelegate* _exportDelegate;

  HourNumberFormatter* _scheduleIntervalHourFormatter;
}


#pragma mark - Initializers -

- (instancetype)initWithExportDelegate:(ExportDelegate*)exportDelegate forHelperDelegate:(HelperDelegate*)helperDelegate {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _helperDelegate = helperDelegate;

  _exportDelegate = exportDelegate;

//  [ExportConfiguration.sharedConfig dumpProperties];
//  [ScheduleConfiguration.sharedConfig dumpProperties];

  // ensure helper registration status matches configuration value for scheduleEnabled
  [_helperDelegate updateHelperRegistrationWithScheduleEnabled:ScheduleConfiguration.sharedConfig.scheduleEnabled];


  return self;
}


#pragma mark - Accessors -

- (id)firstResponderView {

  return _libraryPathTextField;
}


#pragma mark - Mutators -

- (void)viewDidLoad {

  [super viewDidLoad];

  _scheduleIntervalHourFormatter = [[HourNumberFormatter alloc] init];
  [_scheduleIntervalTextField setFormatter:_scheduleIntervalHourFormatter];

  [_exportProgressBar setIndeterminate:NO];
  [_exportProgressBar setMinValue:0];
  [_exportProgressBar setMaxValue:100];
  [_exportProgressBar setDoubleValue:0];
  [_exportStateLabel setStringValue:@"Idle"];

  [self updateFromConfiguration];
}

- (void)updateFromConfiguration {

  NSLog(@"ConfigurationViewController [updateFromConfiguration]");

  [_libraryPathTextField setStringValue:ExportConfiguration.sharedConfig.musicLibraryPath];
  [_outputDirectoryTextField setStringValue:ExportConfiguration.sharedConfig.outputDirectoryUrlPath];
  [_outputFileNameTextField setStringValue:ExportConfiguration.sharedConfig.outputFileName];

  [_remapRootDirectoryCheckBox setState:(ExportConfiguration.sharedConfig.remapRootDirectory ? NSControlStateValueOn : NSControlStateValueOff)];
  [_remapOriginalDirectoryTextField setStringValue:ExportConfiguration.sharedConfig.remapRootDirectoryOriginalPath];
  [_remapMappedDirectoryTextField setStringValue:ExportConfiguration.sharedConfig.remapRootDirectoryMappedPath];

  [_flattenPlaylistsCheckBox setState:(ExportConfiguration.sharedConfig.flattenPlaylistHierarchy ? NSControlStateValueOn : NSControlStateValueOff)];
  [_includeInternalPlaylistsCheckBox setState:(ExportConfiguration.sharedConfig.includeInternalPlaylists ? NSControlStateValueOn : NSControlStateValueOff)];
  //[_excludedPlaylistsTextField setStringValue:ExportConfiguration.sharedConfig.excludedPlaylistPersistentIds];

  [_scheduleEnabledCheckBox setState:ScheduleConfiguration.sharedConfig.scheduleEnabled];
  [_scheduleIntervalTextField setDoubleValue:ScheduleConfiguration.sharedConfig.scheduleInterval/3600];
  [_scheduleIntervalStepper setDoubleValue:ScheduleConfiguration.sharedConfig.scheduleInterval/3600];
  [_scheduleSkipOnBatteryCheckBox setState:ScheduleConfiguration.sharedConfig.skipOnBattery];

  [_lastExportLabel setStringValue:[NSString stringWithFormat:@"Last export:  %@", ScheduleConfiguration.sharedConfig.lastExportedAt ? ScheduleConfiguration.sharedConfig.lastExportedAt.description : @"n/a"]];
  [_nextExportLabel setStringValue:[NSString stringWithFormat:@"Next export:  %@", ScheduleConfiguration.sharedConfig.nextExportAt ? ScheduleConfiguration.sharedConfig.nextExportAt.description : @"n/a"]];

  // update states of controls with dependencies
  [_remapOriginalDirectoryTextField setEnabled:ExportConfiguration.sharedConfig.remapRootDirectory];
  [_remapMappedDirectoryTextField setEnabled:ExportConfiguration.sharedConfig.remapRootDirectory];
  [_scheduleIntervalTextField setEnabled:ScheduleConfiguration.sharedConfig.scheduleEnabled];
  [_scheduleIntervalStepper setEnabled:ScheduleConfiguration.sharedConfig.scheduleEnabled];
  [_scheduleSkipOnBatteryCheckBox setEnabled:ScheduleConfiguration.sharedConfig.scheduleEnabled];
}

- (IBAction)setMediaFolderLocation:(id)sender {

  NSString* mediaFolder = [sender stringValue];

  [ExportConfiguration.sharedConfig setMusicLibraryPath:mediaFolder];
}

- (IBAction)browseOutputDirectory:(id)sender {

  NSLog(@"ConfigurationViewController [browseOutputDirectory]");

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

        [ExportConfiguration.sharedConfig setOutputDirectoryUrl:outputDirUrl];
        [ExportConfiguration.sharedConfig setOutputDirectoryPath:outputDirUrl.path];
        [self->_outputDirectoryTextField setStringValue:outputDirUrl.path];
      }
    }
  }];
}

- (IBAction)setOutputFileName:(id)sender {

  NSString* outputFileName = [sender stringValue];

  [ExportConfiguration.sharedConfig setOutputFileName:outputFileName];
}

- (IBAction)setRemapRootDirectory:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [ExportConfiguration.sharedConfig setRemapRootDirectory:flag];

  [_remapOriginalDirectoryTextField setEnabled:flag];
  [_remapMappedDirectoryTextField setEnabled:flag];
}

- (IBAction)setRemapOriginalText:(id)sender {

  NSString* remapOriginalText = [sender stringValue];

  [ExportConfiguration.sharedConfig setRemapRootDirectoryOriginalPath:remapOriginalText];
}

- (IBAction)setRemapReplacementText:(id)sender {

  NSString* remapReplacementText = [sender stringValue];

  [ExportConfiguration.sharedConfig setRemapRootDirectoryMappedPath:remapReplacementText];
}

- (IBAction)setFlattenPlaylistHierarchy:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [ExportConfiguration.sharedConfig setFlattenPlaylistHierarchy:flag];
}

- (IBAction)setIncludeInternalPlaylists:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [ExportConfiguration.sharedConfig setIncludeInternalPlaylists:flag];
}

- (IBAction)setScheduleEnabled:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [ScheduleConfiguration.sharedConfig setScheduleEnabled:flag];
  [_helperDelegate updateHelperRegistrationWithScheduleEnabled:flag];

  [_scheduleIntervalTextField setEnabled:flag];
  [_scheduleIntervalStepper setEnabled:flag];
  [_scheduleSkipOnBatteryCheckBox setEnabled:flag];
}

- (IBAction)customizePlaylists:(id)sender {

  [(AppDelegate*)NSApp.delegate showPlaylistsView];
}

- (IBAction)setScheduleInterval:(id)sender {

  NSTimeInterval scheduleInterval = [sender doubleValue];

  if (ScheduleConfiguration.sharedConfig.scheduleInterval != scheduleInterval && ScheduleConfiguration.sharedConfig.scheduleEnabled) {

    if (scheduleInterval == 0) {
      scheduleInterval = 1;
    }

    [_scheduleIntervalTextField setDoubleValue:scheduleInterval];
    [ScheduleConfiguration.sharedConfig setScheduleInterval:scheduleInterval * 3600];
    [_scheduleIntervalStepper setDoubleValue:scheduleInterval];
  }
}

- (IBAction)incrementScheduleInterval:(id)sender {

  NSTimeInterval scheduleInterval = [sender doubleValue];

  if (ScheduleConfiguration.sharedConfig.scheduleInterval != scheduleInterval && ScheduleConfiguration.sharedConfig.scheduleEnabled) {

    if (scheduleInterval == 0) {
      scheduleInterval = 1;
    }
    [_scheduleIntervalTextField setDoubleValue:scheduleInterval];
    [ScheduleConfiguration.sharedConfig setScheduleInterval:scheduleInterval * 3600];
    [_scheduleIntervalStepper setDoubleValue:scheduleInterval];
  }
}

- (IBAction)setScheduleSkipOnBattery:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  if (ScheduleConfiguration.sharedConfig.scheduleEnabled) {
    [ScheduleConfiguration.sharedConfig setSkipOnBattery:flag];
  }
}

- (IBAction)exportLibrary:(id)sender {

  dispatch_queue_attr_t queuePriorityAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
  dispatch_queue_t gcdQueue = dispatch_queue_create("ExportQueue", queuePriorityAttr);

  // prepare ExportDelegate members
  BOOL delegateReady = [_exportDelegate prepareForExport];
  if (!delegateReady) {
    NSLog(@"ConfigurationViewController [exportLibrary] error - failed to prepare export delegate");
    return;
  }

  NSUInteger trackCount = _exportDelegate.includedTracks.count;

  [_exportProgressBar setDoubleValue:0];
  [_exportProgressBar setMinValue:0];
  [_exportProgressBar setMaxValue:trackCount];

  dispatch_async(gcdQueue, ^{

    void (^progressCallback)(NSUInteger) = ^(NSUInteger currentTrack){ [self handleTrackExportProgress:currentTrack withTotal:trackCount]; };
    [self->_exportDelegate setTrackProgressCallback:progressCallback];
    
    void (^stateCallback)(NSInteger) = ^(NSInteger state){ [self handleStateChange:state]; };
    [self->_exportDelegate setStateCallback:stateCallback];

    [self->_exportDelegate exportLibrary];
  });
}

- (void)handleTrackExportProgress:(NSUInteger)currentTrack withTotal:(NSUInteger)trackCount {

//  NSLog(@"ConfigurationViewController [handleTrackExportProgress %lu/%lu]", currentTrack, trackCount);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [self->_exportProgressBar setDoubleValue:currentTrack];
    [self->_exportStateLabel setStringValue:[NSString stringWithFormat:@"Generating track %lu/%lu", currentTrack+1, trackCount]];
  });
}

- (void)handleStateChange:(ExportState)exportState {

  dispatch_async(dispatch_get_main_queue(), ^{

    NSString* stateDescription = [Utils descriptionForExportState:exportState];

    NSLog(@"ConfigurationViewController [handleStateChange: %@]", stateDescription);

    [self->_exportStateLabel setStringValue:stateDescription];

    if (exportState == ExportFinished) {
      [ScheduleConfiguration.sharedConfig setLastExportedAt:[NSDate date]];
    }
  });
}

@end
