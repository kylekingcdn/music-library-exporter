//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import "Logger.h"
#import "ExportConfiguration.h"
#import "ScheduleConfiguration.h"
#import "HourNumberFormatter.h"
#import "AppDelegate.h"
#import "ExportManager.h"
#import "DirectoryBookmarkHandler.h"


@interface ConfigurationViewController ()

@property (weak) IBOutlet NSTextField *libraryPathTextField;
@property (weak) IBOutlet NSTextField *outputDirectoryTextField;
@property (weak) IBOutlet NSButton *outputDirectoryBrowseButton;
@property (weak) IBOutlet NSTextField *outputFileNameTextField;

@property (weak) IBOutlet NSButton *remapRootDirectoryCheckBox;
@property (weak) IBOutlet NSTextField *remapOriginalDirectoryTextField;
@property (weak) IBOutlet NSTextField *remapMappedDirectoryTextField;
@property (weak) IBOutlet NSButton *remapLocalhostPrefixCheckBox;

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

  ExportConfiguration* _exportConfiguration;

  ScheduleConfiguration* _scheduleConfiguration;
  HourNumberFormatter* _scheduleIntervalHourFormatter;
}


NSErrorDomain const __MLE_ErrorDomain_ConfigurationView = @"com.kylekingcdn.MusicLibraryExporter.ConfigurationViewErrorDomain";


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super initWithNibName:@"ConfigurationView" bundle:nil]) {

    _exportConfiguration = nil;

    _scheduleConfiguration = nil;
    _scheduleIntervalHourFormatter = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithExportConfiguration:(ExportConfiguration*)exportConfiguration
                   andScheduleConfiguration:(ScheduleConfiguration*)scheduleConfiguration {

  if (self = [self init]) {

    _exportConfiguration = exportConfiguration;
    _scheduleConfiguration = scheduleConfiguration;

    return self;
  }
  else {
    return nil;
  }
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

  [_libraryPathTextField setStringValue:_exportConfiguration.musicLibraryPath];
  [_outputDirectoryTextField setStringValue:_exportConfiguration.outputDirectoryUrlAsPath];
  [_outputFileNameTextField setStringValue:_exportConfiguration.outputFileName];

  [_remapRootDirectoryCheckBox setState:(_exportConfiguration.remapRootDirectory ? NSControlStateValueOn : NSControlStateValueOff)];
  [_remapOriginalDirectoryTextField setStringValue:_exportConfiguration.remapRootDirectoryOriginalPath];
  [_remapMappedDirectoryTextField setStringValue:_exportConfiguration.remapRootDirectoryMappedPath];
  [_remapLocalhostPrefixCheckBox setState:(_exportConfiguration.remapRootDirectoryLocalhostPrefix ? NSControlStateValueOn : NSControlStateValueOff)];

  [_flattenPlaylistsCheckBox setState:(_exportConfiguration.flattenPlaylistHierarchy ? NSControlStateValueOn : NSControlStateValueOff)];
  [_includeInternalPlaylistsCheckBox setState:(_exportConfiguration.includeInternalPlaylists ? NSControlStateValueOn : NSControlStateValueOff)];
  //[_excludedPlaylistsTextField setStringValue:_exportConfiguration.excludedPlaylistPersistentIds];

  [_scheduleEnabledCheckBox setState:_scheduleConfiguration.scheduleEnabled];
  [_scheduleIntervalTextField setDoubleValue:_scheduleConfiguration.scheduleInterval/3600];
  [_scheduleIntervalStepper setDoubleValue:_scheduleConfiguration.scheduleInterval/3600];
  [_scheduleSkipOnBatteryCheckBox setState:_scheduleConfiguration.skipOnBattery];

  NSString* lastExportDescription = @"n/a";
  if (_scheduleConfiguration.lastExportedAt) {
    lastExportDescription = [NSDateFormatter localizedStringFromDate:_scheduleConfiguration.lastExportedAt dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
  }
  NSString* nextExportDescription = @"n/a";
  if (_scheduleConfiguration.nextExportAt) {
    nextExportDescription = [NSDateFormatter localizedStringFromDate:_scheduleConfiguration.nextExportAt dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
  }

  [_lastExportLabel setStringValue:[NSString stringWithFormat:@"Last export:  %@", lastExportDescription]];
  [_nextExportLabel setStringValue:[NSString stringWithFormat:@"Next export:  %@", nextExportDescription]];

  // update states of controls with dependencies
  [_remapOriginalDirectoryTextField setEnabled:_exportConfiguration.remapRootDirectory];
  [_remapMappedDirectoryTextField setEnabled:_exportConfiguration.remapRootDirectory];
  [_remapLocalhostPrefixCheckBox setEnabled:_exportConfiguration.remapRootDirectory];
  [_scheduleIntervalTextField setEnabled:_scheduleConfiguration.scheduleEnabled];
  [_scheduleIntervalStepper setEnabled:_scheduleConfiguration.scheduleEnabled];
  [_scheduleSkipOnBatteryCheckBox setEnabled:_scheduleConfiguration.scheduleEnabled];
}

- (IBAction)setMediaFolderLocation:(id)sender {

  NSString* mediaFolder = [sender stringValue];

  [_exportConfiguration setMusicLibraryPath:mediaFolder];
}

- (IBAction)browseAndValidateOutputDirectory:(id)sender {

  [self browseAndValidateOutputDirectoryWithCallback:^(BOOL isValid) {

    MLE_Log_Info(@"ConfigurationViewController [browseAndValidateOutputDirectoryWithCallback] valid directory selected: %@", (isValid ? @"YES" : @"NO"));
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

  [_remapOriginalDirectoryTextField setEnabled:flag];
  [_remapMappedDirectoryTextField setEnabled:flag];
  [_remapLocalhostPrefixCheckBox setEnabled:flag];
}

- (IBAction)setRemapOriginalText:(id)sender {

  NSString* remapOriginalText = [sender stringValue];

  [_exportConfiguration setRemapRootDirectoryOriginalPath:remapOriginalText];
}

- (IBAction)setRemapReplacementText:(id)sender {

  NSString* remapReplacementText = [sender stringValue];

  [_exportConfiguration setRemapRootDirectoryMappedPath:remapReplacementText];
}

- (IBAction)setRemapLocalhostPrefix:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  [_exportConfiguration setRemapRootDirectoryLocalhostPrefix:flag];
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

  if (flag == NO) {
    [_scheduleConfiguration setNextExportAt:nil];
  }
  [_scheduleConfiguration setScheduleEnabled:flag];

  [_scheduleIntervalTextField setEnabled:flag];
  [_scheduleIntervalStepper setEnabled:flag];
  [_scheduleSkipOnBatteryCheckBox setEnabled:flag];
}

- (IBAction)customizePlaylists:(id)sender {

  [(AppDelegate*)NSApp.delegate showPlaylistsView:nil];
}

- (IBAction)setScheduleInterval:(id)sender {

  NSTimeInterval scheduleInterval = [sender doubleValue];

  if (_scheduleConfiguration.scheduleInterval != scheduleInterval && _scheduleConfiguration.scheduleEnabled) {

    if (scheduleInterval == 0) {
      scheduleInterval = 1;
    }

    [_scheduleIntervalTextField setDoubleValue:scheduleInterval];
    [_scheduleConfiguration setScheduleInterval:scheduleInterval * 3600];
    [_scheduleIntervalStepper setDoubleValue:scheduleInterval];
  }
}

- (IBAction)incrementScheduleInterval:(id)sender {

  NSTimeInterval scheduleInterval = [sender doubleValue];

  if (_scheduleConfiguration.scheduleInterval != scheduleInterval && _scheduleConfiguration.scheduleEnabled) {

    if (scheduleInterval == 0) {
      scheduleInterval = 1;
    }
    [_scheduleIntervalTextField setDoubleValue:scheduleInterval];
    [_scheduleConfiguration setScheduleInterval:scheduleInterval * 3600];
    [_scheduleIntervalStepper setDoubleValue:scheduleInterval];
  }
}

- (IBAction)setScheduleSkipOnBattery:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  if (_scheduleConfiguration.scheduleEnabled) {
    [_scheduleConfiguration setSkipOnBattery:flag];
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

  // resolve output filename (fallback to default if none provided)
  NSString* outputFileName = _exportConfiguration.outputFileName;
  if (outputFileName == nil || outputFileName.length == 0) {
    outputFileName = @"Library.xml";
    MLE_Log_Info(@"ConfigurationViewController [exportLibrary] output filename unspecified - falling back to default: %@", outputFileName);
  }

  // resolve output directory
  DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
  NSError* bookmarkResolveError;
  NSURL* outputDirectoryURL = [bookmarkHandler urlFromDefaultsAndReturnError:&bookmarkResolveError];
  if (outputDirectoryURL == nil) {
    MLE_Log_Info(@"ConfigurationViewController [exportLibrary] unable to retrieve output directory url: %@", bookmarkResolveError);
  }

  // init outputFileURL from OutputDirectoryURL anbd outputFileName
  NSURL* outputFileURL = [outputDirectoryURL URLByAppendingPathComponent:outputFileName];

  ExportManager* exportManager = [[ExportManager alloc] initWithConfiguration:_exportConfiguration];
  [exportManager setDelegate:self];
  [exportManager setOutputFileURL:outputFileURL];

  dispatch_async(gcdQueue, ^{

    /* ---- scoped security access started ---- */
    [outputDirectoryURL startAccessingSecurityScopedResource];

    // run export
    NSError* exportError;
    BOOL exportSuccessful = [exportManager exportLibraryWithError:&exportError];

    [outputDirectoryURL stopAccessingSecurityScopedResource];
    /* ---- scoped security access stopped ---- */

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


- (BOOL)validateOutputDirectory:(NSURL*)outputDirectoryURL error:(NSError**)error {

  BOOL outputDirectoryWritable = [[NSFileManager defaultManager] isWritableFileAtPath:outputDirectoryURL.path];

  // selected directory isn't writable, create alert that prompts user to re-select a directory
  if (!outputDirectoryWritable) {

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

- (void)browseForOutputDirectoryWithCallback:(nullable void(^)(NSURL* _Nullable outputDirectoryURL))callback {

  MLE_Log_Info(@"ConfigurationViewController [browseOutputDirectory]");

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setMessage:@"Select a location to save the generated library."];

  NSWindow* window = [[self view] window];

  [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {

    NSURL* outputDirectoryURL;

    if (result == NSModalResponseOK) {
      outputDirectoryURL = [openPanel URL];
    }

    // if callback is specified, call it with (potentially nil) outputDirectoryURL
    if (callback) {
      callback(outputDirectoryURL);
    }
  }];
}

- (void)browseAndValidateOutputDirectoryWithCallback:(nullable void(^)(BOOL isValid))callback {

  [self browseForOutputDirectoryWithCallback:^(NSURL* _Nullable outputDirectoryURL){

    if (outputDirectoryURL == nil) {
      if (callback) {
        callback(NO);
      }
      return;
    }

    NSError* validationError;
    BOOL outputDirIsValid = [self validateOutputDirectory:outputDirectoryURL error:&validationError];

    // selected directory is valid
    if (outputDirIsValid) {

      // save bookmark url for selected directory
      DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
      [bookmarkHandler saveURLToDefaults:outputDirectoryURL];

      // update text field
//      [self->_outputDirectoryTextField setStringValue:outputDirectoryURL.path];

      if (callback) {
        callback(YES);
      }

      return;
    }

    // -- invalid directory

    // no error given, execute callback
    if (validationError == nil) {
      if (callback != nil) {
        callback(NO);
      }
    }
    else {
      // this error gives the option for re-selecting a directory.
      // Re-call this function, pass (and don't call) the callback if re-select button is clicked
      if (validationError.code == ConfigurationViewErrorOutputDirectoryUnwritable) {

        [self showAlertForError:validationError callback:^(NSModalResponse response) {
          if (response == NSAlertFirstButtonReturn) {
            [self browseAndValidateOutputDirectoryWithCallback:callback];
            return;
          }
          else {
            if (callback != nil) {
              callback(NO);
            }
          }
        }];
      }

      // errors that don't provide user resolution options
      else {
        [self showAlertForError:validationError callback:nil];
        if (callback != nil) {
          callback(NO);
        }
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

- (void)exportStateChangedFrom:(ExportState)oldState toState:(ExportState)newState {

  NSString* stateDescription = ExportStateNames[newState];

  MLE_Log_Info(@"ConfigurationViewController [handleStateChange: %@]", stateDescription);

  // handle UI updates in main thread
  dispatch_async(dispatch_get_main_queue(), ^{

    BOOL exportAllowed;
    switch (newState) {
      case ExportFinished:
        [self->_scheduleConfiguration setLastExportedAt:[NSDate date]];
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

- (void)exportedItems:(NSUInteger)exportedItems ofTotal:(NSUInteger)totalItems {

  // handle UI updates in main thread
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_exportProgressBar.maxValue != totalItems) {
      [self->_exportProgressBar setMaxValue:totalItems];
    }
    [self->_exportProgressBar setDoubleValue:exportedItems];
    [self->_exportStateLabel setStringValue:[NSString stringWithFormat:@"Generating track %lu/%lu", exportedItems, totalItems]];
  });
}

- (void)exportedPlaylists:(NSUInteger)exportedPlaylists ofTotal:(NSUInteger)totalPlaylists {

}

@end
