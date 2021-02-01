//
//  ConfigurationViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import "ConfigurationViewController.h"

#import <iTunesLibrary/ITLibrary.h>
#import <ServiceManagement/ServiceManagement.h>

#import "UserDefaultsExportConfiguration.h"


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

@property (weak) IBOutlet NSButton *exportLibraryButton;

@end


@implementation ConfigurationViewController

- (instancetype)init {

  self = [super initWithNibName: @"ConfigurationView" bundle: nil];

  _exportConfiguration = [[UserDefaultsExportConfiguration alloc] initWithUserDefaultsSuiteName:_appGroupIdentifier];
  _librarySerializer = [[LibrarySerializer alloc] init];
  
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
//  [_scheduleEnabledCheckBox setState:_exportConfiguration.scheduleEnabled];
//  [_scheduleIntervalTextField setIntegerValue:_exportConfiguration.scheduleInterval];
//  [_scheduleIntervalStepper setIntegerValue:_exportConfiguration.scheduleInterval];
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

- (IBAction)browseOutputDirectory:(id)sender {

  NSLog(@"[browseOutputDirectory]");

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setMessage:@"Select a location to save the generated library."];

  NSWindow* window = [[self view] window];

  [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {

    if (result == NSFileHandlingPanelOKButton) {

      NSURL* outputDirUrl = [openPanel URL];
      if (outputDirUrl) {

        NSString* outputDirPath = outputDirUrl.path;
        [self->_exportConfiguration setOutputDirectoryPath:outputDirPath];
        [self->_outputDirectoryTextField setStringValue:outputDirPath];

        [self saveBookmarkForOutputDirectoryUrl:outputDirUrl];
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

//  [_exportConfiguration setScheduleEnabled:flag];

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
//  [_exportConfiguration setScheduleInterval:scheduleInterval];
}

- (IBAction)incrementScheduleInterval:(id)sender {

//  NSStepper* stepper = (NSStepper*)sender;
  NSInteger scheduleInterval = [sender integerValue];

  NSLog(@"[incrementScheduleInterval: %ld]", scheduleInterval);

  [_scheduleIntervalTextField setIntegerValue:scheduleInterval];
//  [_exportConfiguration setScheduleInterval:scheduleInterval];
}

- (IBAction)exportLibraryAction:(id)sender {

  BOOL exportSuccessful = [self exportLibrary];

  if (!exportSuccessful) {
    NSLog(@"[exportLibraryAction] library export has failed");
  }
}

- (BOOL)exportLibrary {

  // FIXME: use bookmarked output dir
  if (!_exportConfiguration.outputDirectoryPath || _exportConfiguration.outputDirectoryPath.length == 0) {
    NSLog(@"[exportLibrary] error - invalid output directory");
    return NO;
  }

  if (!_exportConfiguration.outputFileName || _exportConfiguration.outputFileName.length == 0) {
    NSLog(@"[exportLibrary] error - invalid output filename");
    return NO;
  }

  [_librarySerializer setIncludeFoldersWhenFlattened:NO];

  [_librarySerializer setRemapRootDirectory:_exportConfiguration.remapRootDirectory];
  [_librarySerializer setOriginalRootDirectory:_exportConfiguration.remapRootDirectoryOriginalPath];
  [_librarySerializer setMappedRootDirectory:_exportConfiguration.remapRootDirectoryMappedPath];

  [_librarySerializer setFlattenPlaylistHierarchy:_exportConfiguration.flattenPlaylistHierarchy];
  [_librarySerializer setIncludeInternalPlaylists:_exportConfiguration.includeInternalPlaylists];

  NSError *initLibraryError = nil;
  ITLibrary *itLibrary = [ITLibrary libraryWithAPIVersion:@"1.1" error:&initLibraryError];
  if (!itLibrary) {
    NSLog(@"[exportLibrary]  error - failed to init ITLibrary. error: %@", initLibraryError.localizedDescription);
    return NO;
  }

  NSURL* outputDirectoryUrl = [self resolveAndAutoRenewOutputDirectoryUrl];
  if (!outputDirectoryUrl) {
    NSLog(@"[exportLibrary] unable to retrieve output directory - a directory must be selected to obtain write permission");
    return NO;
  }

  NSLog(@"[exportLibrary] output directory url: %@", outputDirectoryUrl);

  // generate full output path
  NSString* outputFilePath = [outputDirectoryUrl.path stringByAppendingPathComponent:_exportConfiguration.outputFileName];
  [_librarySerializer setFilePath:outputFilePath];

  // serialize library
  NSLog(@"[exportLibrary] serializing library");
  [_librarySerializer serializeLibrary:itLibrary];

  // write library
  NSLog(@"[exportLibrary] saving to path: %@", outputFilePath);
  [outputDirectoryUrl startAccessingSecurityScopedResource];
  [_librarySerializer writeDictionary];
  [outputDirectoryUrl stopAccessingSecurityScopedResource];

  return YES;
}

- (NSData*)fetchOutputDirectoryBookmarkData {

  // fetch save url bookmark
  NSUserDefaults* appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
  NSData* outputDirBookmarkData = [appGroupDefaults dataForKey:@"OutputDirectoryBookmark"];

  return outputDirBookmarkData;
}

- (NSURL*)resolveAndAutoRenewOutputDirectoryUrl {

  // fetch output directory bookmark data
  NSData* outputDirBookmarkData = [self fetchOutputDirectoryBookmarkData];

  // no bookmark has been saved yet
  if (!outputDirBookmarkData) {
    return nil;
  }

  // resolve output directory URL for bookmark data
  BOOL outputDirBookmarkIsStale;
  NSError* outputDirBookmarkResolutionError;
  NSURL* outputDirBookmarkUrl = [NSURL URLByResolvingBookmarkData:outputDirBookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&outputDirBookmarkIsStale error:&outputDirBookmarkResolutionError];

  // error resolving bookmark data
  if (outputDirBookmarkResolutionError) {
    NSLog(@"[fetchAndAutoRenewOutputDirectoryUrl] error resolving output dir bookmark: %@", outputDirBookmarkResolutionError.localizedDescription);
    return nil;
  }

  NSAssert(outputDirBookmarkUrl != nil, @"NSURL retreived from bookmark is nil");
  NSLog(@"[fetchAndAutoRenewOutputDirectoryUrl] bookmarked output directory: %@", outputDirBookmarkUrl.path);

  // bookmark data is stale, attempt to renew
  if (outputDirBookmarkIsStale) {

    NSError* outputDirBookmarkRenewError;
    NSLog(@"[fetchAndAutoRenewOutputDirectoryUrl] bookmark is stale, attempting renewal");

    [outputDirBookmarkUrl startAccessingSecurityScopedResource];
    outputDirBookmarkData = [outputDirBookmarkUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&outputDirBookmarkRenewError];
    [outputDirBookmarkUrl stopAccessingSecurityScopedResource];

    if (outputDirBookmarkRenewError) {
      NSLog(@"[fetchAndAutoRenewOutputDirectoryUrl] error renewing bookmark: %@", outputDirBookmarkRenewError.localizedDescription);
      return nil;
    }
  }
  else {
    NSLog(@"[fetchAndAutoRenewOutputDirectoryUrl] bookmarked output directory is valid");
  }

  return outputDirBookmarkUrl;
}

- (BOOL)saveBookmarkForOutputDirectoryUrl:(NSURL*)outputDirUrl {

  NSLog(@"[saveBookmarkForOutputDirectoryUrl: %@]", outputDirUrl);

  NSError* outputDirBookmarkError;
  NSData* outputDirBookmarkData = [outputDirUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&outputDirBookmarkError];

  // error generating bookmark
  if (outputDirBookmarkError) {
    NSLog(@"[saveBookmarkForOutputDirectoryUrl] error generating output directory bookmark data: %@", outputDirBookmarkError.localizedDescription);
    return NO;
  }

  // save bookmark data to user defaults
  else {
    NSUserDefaults* appGroupDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroupIdentifier];
    [appGroupDefaults setValue:outputDirBookmarkData forKey:@"OutputDirectoryBookmark"];
    return YES;
  }
}

@end
