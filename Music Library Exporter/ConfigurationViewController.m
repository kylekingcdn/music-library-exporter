//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import "Logger.h"
#import "Utils.h"
#import "HelperDelegate.h"
#import "UserDefaultsExportConfiguration.h"
#import "ScheduleConfiguration.h"
#import "HourNumberFormatter.h"
#import "AppDelegate.h"
#import "ExportManager.h"


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

  HourNumberFormatter* _scheduleIntervalHourFormatter;
}


NSErrorDomain const __MLE_ErrorDomain_ConfigurationView = @"com.kylekingcdn.MusicLibraryExporter.ConfigurationViewErrorDomain";


#pragma mark - Initializers

- (instancetype)initWithHelperDelegate:(HelperDelegate*)helperDelegate {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _helperDelegate = helperDelegate;

//  [ExportConfiguration.sharedConfig dumpProperties];
//  [ScheduleConfiguration.sharedConfig dumpProperties];

  // ensure helper registration status matches configuration value for scheduleEnabled
  [_helperDelegate updateHelperRegistrationWithScheduleEnabled:ScheduleConfiguration.sharedConfig.scheduleEnabled];


  return self;
}


#pragma mark - Accessors

- (id)firstResponderView {

  return _libraryPathTextField;
}


#pragma mark - Mutators

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

  MLE_Log_Info(@"ConfigurationViewController [updateFromConfiguration]");

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

  NSString* lastExportDescription = @"n/a";
  if (ScheduleConfiguration.sharedConfig.lastExportedAt) {
    lastExportDescription = [NSDateFormatter localizedStringFromDate:ScheduleConfiguration.sharedConfig.lastExportedAt dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
  }
  NSString* nextExportDescription = @"n/a";
  if (ScheduleConfiguration.sharedConfig.nextExportAt) {
    nextExportDescription = [NSDateFormatter localizedStringFromDate:ScheduleConfiguration.sharedConfig.nextExportAt dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
  }

  [_lastExportLabel setStringValue:[NSString stringWithFormat:@"Last export:  %@", lastExportDescription]];
  [_nextExportLabel setStringValue:[NSString stringWithFormat:@"Next export:  %@", nextExportDescription]];

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

- (IBAction)browseAndValidateOutputDirectory:(id)sender {

  [self browseAndValidateOutputDirectoryWithCallback:^(BOOL isValid) {

    MLE_Log_Info(@"ConfigurationViewController [browseAndValidateOutputDirectoryWithCallback] valid directory selected: %@", (isValid ? @"YES" : @"NO"));
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

  if (flag == NO) {
    [ScheduleConfiguration.sharedConfig setNextExportAt:nil];
  }
  [ScheduleConfiguration.sharedConfig setScheduleEnabled:flag];

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

  // catch any changes made to configuration form before updating UI
  [[[self view] window] makeFirstResponder:self.view.window];

  dispatch_queue_attr_t queuePriorityAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
  dispatch_queue_t gcdQueue = dispatch_queue_create("ExportQueue", queuePriorityAttr);

  // reset track progress values in main thread first
  [_exportProgressBar setDoubleValue:0];
  [_exportProgressBar setMinValue:0];

  /* -- temp -- generate output file url */
  NSError* outputDirResolveError;
  NSURL* outputDirectoryUrl = [UserDefaultsExportConfiguration.sharedConfig resolveOutputDirectoryBookmarkAndReturnError:&outputDirResolveError];
  if (outputDirectoryUrl == nil) {
    MLE_Log_Info(@"ConfigurationViewController [exportLibrary] unable to retrieve output directory - a directory must be selected to obtain write permission");
  }
  NSString* outputFileName = UserDefaultsExportConfiguration.sharedConfig.outputFileName;
  if (outputFileName == nil || outputFileName.length == 0) {
    outputFileName = @"Library.xml"; // fallback to default filename
    MLE_Log_Info(@"ConfigurationViewController [exportLibrary] output filename unspecified - falling back to default: %@", outputFileName);
  }
  // TODO: handle output directory validation
  NSURL* outputFileUrl = [outputDirectoryUrl URLByAppendingPathComponent:outputFileName];
  /* -- temp -- */

  dispatch_async(gcdQueue, ^{

    ExportManager* exportManager = [[ExportManager alloc] initWithConfiguration:UserDefaultsExportConfiguration.sharedConfig];
    [exportManager setDelegate:self];
    [exportManager setOutputFileURL:outputFileUrl];

    NSError* exportError;
    [outputDirectoryUrl startAccessingSecurityScopedResource];
    BOOL exportSuccessful = [exportManager exportLibraryWithError:&exportError];
    [outputDirectoryUrl stopAccessingSecurityScopedResource];

    MLE_Log_Info(@"ConfigurationViewController [exportLibrary] export successful: %@", (exportSuccessful ? @"YES" : @"NO"));

    // handle export errors
    if (!exportSuccessful) {

      if (exportError) {
        [self showAlertForError:exportError callback:nil];
      }
      else {
        MLE_Log_Error(@"ConfigurationViewController [exportLibrary] error - an unknown error occurred");
      }
      return;
    }
  });
}


- (BOOL)validateOutputDirectory:(NSURL*)outputDirUrl error:(NSError**)error {

  BOOL outputDirWritable = [[NSFileManager defaultManager] isWritableFileAtPath:outputDirUrl.path];

  // selected directory isn't writable, create alert that prompts user to re-select a directory
  if (!outputDirWritable) {

    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ConfigurationView code:ConfigurationViewErrorOutputDirectoryUnwritable userInfo:@{
        NSLocalizedDescriptionKey: @"You do not have permission to save to this directory",
        NSLocalizedRecoverySuggestionErrorKey: @"Would you like to select a new directory?",
        NSLocalizedRecoveryOptionsErrorKey: @[ @"Browse", @"Cancel" ],
      }];
    }

    return NO;
  }

  return YES;
}

- (void)browseForOutputDirectoryWithCallback:(nullable void(^)(NSURL* _Nullable outputUrl))callback {

  MLE_Log_Info(@"ConfigurationViewController [browseOutputDirectory]");

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setMessage:@"Select a location to save the generated library."];

  NSWindow* window = [[self view] window];

  [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {

    NSURL* outputDirUrl;

    if (result == NSModalResponseOK) {
      outputDirUrl = [openPanel URL];
    }

    // if callback is specified, call it with (potentially nil) outputDirUrl
    if (callback) {
      callback(outputDirUrl);
    }
  }];
}

- (void)browseAndValidateOutputDirectoryWithCallback:(nullable void(^)(BOOL isValid))callback {

  [self browseForOutputDirectoryWithCallback:^(NSURL* _Nullable outputDirUrl){

    if (outputDirUrl == nil) {
      if (callback) {
        callback(NO);
      }
      return;
    }

    NSError* validationError;
    BOOL outputDirIsValid = [self validateOutputDirectory:outputDirUrl error:&validationError];

    // selected directory is valid
    if (outputDirIsValid) {

      // update config
      [ExportConfiguration.sharedConfig setOutputDirectoryUrl:outputDirUrl];

      // update text field
      [self->_outputDirectoryTextField setStringValue:outputDirUrl.path];

      if (callback) {
        callback(YES);
      }

      return;
    }

    // -- invalid directory

    // no error given, execute callback and return
    if (validationError == nil) {
      if (callback) {
        callback(NO);
        return;
      }
    }

    // this error gives the option for re-selecting a directory.
    // Re-call this function, pass (and don't call) the callback if re-select button is clicked
    if (validationError.code == ConfigurationViewErrorOutputDirectoryUnwritable) {

      [self showAlertForError:validationError callback:^(NSModalResponse response) {
        if (response == NSAlertFirstButtonReturn) {
          [self browseAndValidateOutputDirectoryWithCallback:callback];
          return;
        }
        else {
          if (callback) {
            callback(NO);
          }
        }
      }];
    }

    // errors that don't provide user resolution options
    else {
      [self showAlertForError:validationError callback:nil];
      if (callback) {
        callback(NO);
      }
    }
  }];
}

- (void)showAlertForError:(NSError*)error callback:(nullable void(^)(NSModalResponse response))callback {

  dispatch_async(dispatch_get_main_queue(), ^{

    MLE_Log_Info(@"ConfigurationViewController [showAlertForError: %@]", error.localizedDescription);

    NSAlert* errorAlert = [NSAlert alertWithError:error];
    NSModalResponse errorAlertResponse = [errorAlert runModal];

    MLE_Log_Debug(@"ConfigurationViewController [showAlertForError] error alert response: %ld", errorAlertResponse);

    if (callback) {
      MLE_Log_Debug(@"ConfigurationViewController [showAlertForError] running callback");
      callback(errorAlertResponse);
    }
  });
}


#pragma mark - ExportManagerDelegate

- (void) exportStateChangedFrom:(ExportState)oldState toState:(ExportState)newState {

  NSString* stateDescription = [Utils descriptionForExportState:newState];

  MLE_Log_Info(@"ConfigurationViewController [handleStateChange: %@]", stateDescription);

  // handle UI updates in main thread
  dispatch_async(dispatch_get_main_queue(), ^{

    BOOL exportAllowed;
    switch (newState) {
      case ExportFinished:
        [ScheduleConfiguration.sharedConfig setLastExportedAt:[NSDate date]];
      case ExportStopped:
      case ExportError: {
        exportAllowed = YES;
        break;
      }
      default: {
        exportAllowed = NO;
        break;
      }
    }
    
    [self->_exportStateLabel setStringValue:stateDescription];
    [self->_exportLibraryButton setEnabled:exportAllowed];
  });
}

- (void) exportedItems:(NSUInteger)exportedItems ofTotal:(NSUInteger)totalItems {

  // handle UI updates in main thread
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_exportProgressBar.maxValue != totalItems) {
      [self->_exportProgressBar setMaxValue:totalItems];
    }
    [self->_exportProgressBar setDoubleValue:exportedItems];
    [self->_exportStateLabel setStringValue:[NSString stringWithFormat:@"Generating track %lu/%lu", exportedItems, totalItems]];
  });
}

- (void) exportedPlaylists:(NSUInteger)exportedPlaylists ofTotal:(NSUInteger)totalPlaylists {

}

@end
