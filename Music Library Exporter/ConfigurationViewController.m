//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import <ServiceManagement/ServiceManagement.h>

#import "ExportConfiguration.h"


static NSString* const _appGroupIdentifier = @"group.9YLM7HTV6V.com.MusicLibraryExporter";
static NSString* const _helperBundleIdentifier = @"com.kylekingcdn.MusicLibraryExporter.MusicLibraryExporterHelper";


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

@end


@implementation ConfigurationViewController

- (instancetype)init {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _exportConfiguration = [[ExportConfiguration alloc] initWithUserDefaults];

  return self;
}

- (void)viewDidLoad {

  [super viewDidLoad];

  _scheduleEnabled = [self isScheduleRegisteredWithSystem];

  NSLog(@"[viewDidLoad] isScheduleRegisteredWithSystem: %@", (_scheduleEnabled ? @"YES" : @"NO"));

  NSUserDefaults* groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
  NSAssert(groupDefaults, @"failed to init NSUSerDefaults for app group");

  if (groupDefaults) {
    [_scheduleEnabledCheckBox setState:(_scheduleEnabled ? NSControlStateValueOn : NSControlStateValueOff)];
  }

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

  // TODO: fix schedule state
  [_scheduleEnabledCheckBox setState:_exportConfiguration.scheduleEnabled];
  [_scheduleIntervalTextField setIntegerValue:_exportConfiguration.scheduleInterval];
  [_scheduleIntervalStepper setIntegerValue:_exportConfiguration.scheduleInterval];
}

- (BOOL)isScheduleRegisteredWithSystem {

  // source: http://blog.mcohen.me/2012/01/12/login-items-in-the-sandbox/
  // > As of WWDC 2017, Apple engineers have stated that [SMCopyAllJobDictionaries] is still the preferred API to use.
  //     ref: https://github.com/alexzielenski/StartAtLoginController/issues/12#issuecomment-307525807

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  CFArrayRef cfJobDictsArr = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
#pragma pop
  NSArray* jobDictsArr = CFBridgingRelease(cfJobDictsArr);

  if (jobDictsArr && jobDictsArr.count > 0) {

    for (NSDictionary* jobDict in jobDictsArr) {

      if ([_helperBundleIdentifier isEqualToString:[jobDict objectForKey:@"Label"]]) {
        return [[jobDict objectForKey:@"OnDemand"] boolValue];
      }
    }
  }

  return NO;
}

- (BOOL)registerSchedulerWithSystem:(BOOL)flag {

  NSLog(@"[registerSchedulerWithSystem:%@]", (flag ? @"YES" : @"NO"));

  BOOL success = SMLoginItemSetEnabled ((__bridge CFStringRef)_helperBundleIdentifier, flag);

  if (success) {
    NSLog(@"[registerSchedulerWithSystem] succesfully %@ scheduler", (flag ? @"registered" : @"unregistered"));
    _scheduleEnabled = YES;
  }
  else {
    NSLog(@"[registerSchedulerWithSystem] failed to %@ scheduler", (flag ? @"register" : @"unregister"));
    _scheduleEnabled = YES;
  }

  return success;
}

- (NSString*)errorForSchedulerRegistration:(BOOL)registerFlag {

  if (registerFlag) {
    return @"Couldn't add Music Library Exporter Helper to launch at login item list.";
  }
  else {
    return @"Couldn't remove Music Library Exporter Helper from launch at login item list.";
  }
}

- (IBAction)setMediaFolderLocation:(id)sender {

  NSString* mediaFolder = [sender stringValue];
  NSLog(@"[setMediaFolderLocation: %@]", mediaFolder);

  [_exportConfiguration setMusicLibraryPath:mediaFolder];
}

- (IBAction)broweOutputDirectory:(id)sender {

  NSLog(@"[broweOutputDirectory]");

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setMessage:@"Select a location to save the generated library."];

  NSWindow* window = [[self view] window];

  [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {

    if (result == NSFileHandlingPanelOKButton) {

      NSArray* urls = [openPanel URLs];

      if (urls.count == 1) {

        NSURL* directoryUrl = urls.firstObject;
        NSString* directoryPath = directoryUrl.path;

        if (directoryPath) {

          NSLog(@"[broweOutputDirectory directory: %@]", directoryPath);

          [self->_exportConfiguration setOutputDirectoryPath:directoryPath];
          [self->_outputDirectoryTextField setStringValue:directoryPath];
        }
      }
    }
  }];
}

- (IBAction)setOutputFileName:(id)sender {

  NSString* outputFileName = [sender stringValue];

  NSLog(@"[setOutputFileName: %@]", outputFileName);

  [_exportConfiguration setOutputFileName:outputFileName];
}

- (IBAction)setRemapRootDirectory:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  NSLog(@"[setRemapRootDirectory: %@]", (flag ? @"YES" : @"NO"));

  [_exportConfiguration setRemapRootDirectory:flag];
}

- (IBAction)setRemapOriginalText:(id)sender {

  NSString* remapOriginalText = [sender stringValue];

  NSLog(@"[setRemapOriginalText: %@]", remapOriginalText);

  [_exportConfiguration setRemapRootDirectoryOriginalPath:remapOriginalText];
}

- (IBAction)setRemapReplacementText:(id)sender {

  NSString* remapReplacementText = [sender stringValue];

  NSLog(@"[setRemapReplacementText: %@]", remapReplacementText);

  [_exportConfiguration setRemapRootDirectoryMappedPath:remapReplacementText];
}

- (IBAction)setFlattenPlaylistHierarchy:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  NSLog(@"[setFlattenPlaylistHierarchy: %@]", (flag ? @"YES" : @"NO"));

  [_exportConfiguration setFlattenPlaylistHierarchy:flag];
}

- (IBAction)setIncludeInternalPlaylists:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  NSLog(@"[setIncludeInternalPlaylists: %@]", (flag ? @"YES" : @"NO"));

  [_exportConfiguration setIncludeInternalPlaylists:flag];
}

- (IBAction)setScheduleEnabled:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  NSLog(@"[setScheduleEnabled: %@]", (flag ? @"YES" : @"NO"));

  [_exportConfiguration setScheduleEnabled:flag];

//  if (![self registerSchedulerWithSystem:flag]) {
//
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setMessageText:@"An error ocurred"];
//    [alert addButtonWithTitle:@"OK"];
//    [alert setInformativeText:[self errorForSchedulerRegistration:flag]];
//
//    [alert runModal];
//  }
}

- (IBAction)setScheduleInterval:(id)sender {

//  NSTextField* textField = (NSTextField*)sender;
  NSInteger scheduleInterval = [sender integerValue];

  NSLog(@"[setScheduleInterval: %ld]", scheduleInterval);

  [_scheduleIntervalStepper setIntegerValue:scheduleInterval];
  [_exportConfiguration setScheduleInterval:scheduleInterval];
}

- (IBAction)incrementScheduleInterval:(id)sender {

//  NSStepper* stepper = (NSStepper*)sender;
  NSInteger scheduleInterval = [sender integerValue];

  NSLog(@"[incrementScheduleInterval: %ld]", scheduleInterval);

  [_scheduleIntervalTextField setIntegerValue:scheduleInterval];
  [_exportConfiguration setScheduleInterval:scheduleInterval];
}

@end
