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

@property (weak) IBOutlet NSTextField *nextExportLabel;
@property (weak) IBOutlet NSTextField *lastExportLabel;

@property (weak) IBOutlet NSButton *exportLibraryButton;
@property (weak) IBOutlet NSTextField *exportStateLabel;
@property (weak) IBOutlet NSProgressIndicator *exportProgressBar;

@end


@implementation ConfigurationViewController {

  HelperDelegate* _helperDelegate;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ExportDelegate* _exportDelegate;

  ScheduleConfiguration* _scheduleConfiguration;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _helperDelegate = [[HelperDelegate alloc] init];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:__MLE__AppGroupIdentifier];
  _exportDelegate = [[ExportDelegate alloc] initWithConfiguration:_exportConfiguration];

  _scheduleConfiguration = [[ScheduleConfiguration alloc] init];

  [_exportConfiguration dumpProperties];
  [_scheduleConfiguration dumpProperties];

  [_exportDelegate dumpProperties];

  // ensure helper registration status matches configuration value for scheduleEnabled
  [_helperDelegate updateHelperRegistrationWithScheduleEnabled:_scheduleConfiguration.scheduleEnabled];
  
  return self;
}


#pragma mark - Mutators -

- (void)viewDidLoad {

  [super viewDidLoad];

  [_exportProgressBar setIndeterminate:NO];
  [_exportProgressBar setMinValue:0];
  [_exportProgressBar setMaxValue:100];
  [_exportProgressBar setDoubleValue:0];

  [self updateFromConfiguration];
}

- (void)updateFromConfiguration {

  NSLog(@"ConfigurationViewController [updateFromConfiguration]");

  [_libraryPathTextField setStringValue:_exportConfiguration.musicLibraryPath];
  [_outputDirectoryTextField setStringValue:_exportConfiguration.outputDirectoryPath];
  [_outputFileNameTextField setStringValue:_exportConfiguration.outputFileName];

  [_remapRootDirectoryCheckBox setState:(_exportConfiguration.remapRootDirectory ? NSControlStateValueOn : NSControlStateValueOff)];
  [_remapOriginalDirectoryTextField setStringValue:_exportConfiguration.remapRootDirectoryOriginalPath];
  [_remapMappedDirectoryTextField setStringValue:_exportConfiguration.remapRootDirectoryMappedPath];

  [_flattenPlaylistsCheckBox setState:(_exportConfiguration.flattenPlaylistHierarchy ? NSControlStateValueOn : NSControlStateValueOff)];
  [_includeInternalPlaylistsCheckBox setState:(_exportConfiguration.includeInternalPlaylists ? NSControlStateValueOn : NSControlStateValueOff)];
  //[_excludedPlaylistsTextField setStringValue:_exportConfiguration.excludedPlaylistPersistentIds];

  [_scheduleEnabledCheckBox setState:_scheduleConfiguration.scheduleEnabled];
  [_scheduleIntervalTextField setIntegerValue:_scheduleConfiguration.scheduleInterval];
  [_scheduleIntervalStepper setIntegerValue:_scheduleConfiguration.scheduleInterval];

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

  [_scheduleConfiguration setScheduleEnabled:flag];

  // register/unregister helper app
  [_helperDelegate updateHelperRegistrationWithScheduleEnabled:flag];
}

- (IBAction)setScheduleInterval:(id)sender {

  NSInteger scheduleInterval = [sender integerValue];

  [_scheduleIntervalStepper setIntegerValue:scheduleInterval];

  [_scheduleConfiguration setScheduleInterval:scheduleInterval];
}

- (IBAction)incrementScheduleInterval:(id)sender {

  NSInteger scheduleInterval = [sender integerValue];

  [_scheduleIntervalTextField setIntegerValue:scheduleInterval];

  [_scheduleConfiguration setScheduleInterval:scheduleInterval];
}

- (IBAction)exportLibrary:(id)sender {

  dispatch_queue_attr_t queuePriorityAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
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
  });
}

@end
